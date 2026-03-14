import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/post_task_home.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Get important user defined services for fetching/altering user and post data
  final _postService = PostService();
  final _userService = UserService();

  // Data holders
  final now = Conversions.getNow();
  Map<DateTime, List<Map<String, dynamic>>> events = {};
  late Map<String, dynamic> userData;
  late List<Map<String, dynamic>> dayPosts;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  // Sets the selected and focused day to current date and fetches all user and
  // posts data
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

  // If the user completed their daily task, the post is updated and the widget
  // refreshes
  void updateDailyPost() {
    final provider = context.read<DailyPostProvider>();

    void listener() {
      init();

      provider.removeListener(listener);
    }

    provider.addListener(listener);
  }

  // Fetch user posts
  Future<void> init() async {
    userData = await _userService.getUserData();

    Map<DateTime, List<Map<String, dynamic>>> newEvents = {};
    Map<String, dynamic>? posts = await _postService.getPosts();
    events.clear();

    if (posts == null) return;

    posts.forEach((dateStr, postData) {
      DateTime date = DateTime.parse(dateStr);
      date = DateTime(date.year, date.month, date.day);
      newEvents[date] = [Map<String, dynamic>.from(postData as Map)];
    });

    setState(() {
      events = newEvents;
    });
  }

  // Shows the callendar page which consist of the callendar and the post tasjk
  // home page, meaning under the callendar, that dates post and friends posts
  // are shown
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RefreshIndicator(
        onRefresh: init,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 10),
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
                    Conversions.getNow().add(const Duration(days: 1)),
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
                          color: context.watch<ThemeProvider>().primaryColor,
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
                key: UniqueKey(),
                date: Conversions.dateToString(_selectedDay),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
