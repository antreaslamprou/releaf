import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/post_task_home.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:table_calendar/table_calendar.dart';

class PostsCalendar extends StatefulWidget {
  const PostsCalendar({super.key});

  @override
  State<PostsCalendar> createState() => PostsCalendarState();
}

class PostsCalendarState extends State<PostsCalendar> {
  final PostService postService = PostService();
  final UserService userService = UserService();
  final now = DateTime.now().toUtc();

  Map<DateTime, List<Map<String, dynamic>>> events = {};

  late Map<String, dynamic> userData;
  late List<Map<String, dynamic>> dayPosts;

  late DateTime _selectedDay;
  late DateTime _focusedDay;

  int postKey = 1;

  @override
  void initState() {
    super.initState();

    _selectedDay = now;
    _focusedDay = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
      updateDailyPost();
    });
  }

  void updateDailyPost() {
    final provider = Provider.of<DailyPostProvider>(context, listen: false);

    void listener() {
      init();

      provider.removeListener(listener);
    }

    provider.addListener(listener);
  }

  Future<void> init() async {
    userData = await userService.getUserData();
    loadEventsFromPosts();
  }

  void loadEventsFromPosts() async {
    Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

    Map<String, dynamic>? posts = await postService.getPosts();
    events.clear();

    if (posts == null) return;

    posts.forEach((dateStr, postData) {
      DateTime date = DateTime.parse(dateStr);
      date = DateTime(date.year, date.month, date.day);
      newEvents[date] = [Map<String, dynamic>.from(postData as Map)];
    });

    setState(() {
      events = newEvents;
      postKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: init,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            TableCalendar(
              sixWeekMonthsEnforced: true,
              availableGestures: AvailableGestures.horizontalSwipe,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              calendarFormat: CalendarFormat.month,
              firstDay: DateTime.utc(2025, 10, 1),
              lastDay: DateTime.utc(now.year, now.month, now.day),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              enabledDayPredicate: (day) {
                return day.isBefore(
                  DateTime.now().toUtc().add(const Duration(days: 1)),
                );
              },
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return events[normalizedDay] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      top: 5,
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 35,
                        color: Colors.green,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 20),
              child: Divider(),
            ),
            PostTaskHome(
              key: ValueKey(postKey),
              date: Conversions.dateToString(_selectedDay),
              isEditable: false,
            ),
          ],
        ),
      ),
    );
  }
}
