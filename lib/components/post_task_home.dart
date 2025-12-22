import 'package:flutter/material.dart';
import 'package:releaf/components/friends_posts.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/pages/task_page.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class PostTaskHome extends StatefulWidget {
  const PostTaskHome({super.key, this.date, this.isEditable = true});

  final String? date;
  final bool isEditable;

  @override
  State<PostTaskHome> createState() => _PostTaskHomeState();
}

class _PostTaskHomeState extends State<PostTaskHome> {
  UserService userService = UserService();
  PostService postService = PostService();
  TaskService taskService = TaskService();

  Map<String, dynamic> postData = {};
  String? userId;
  bool isLoading = true;
  var date = '';
  Map<dynamic, dynamic>? dailyTask;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    String dateTemp = '';
    Map<String, dynamic> postDataTemp = {};
    Map<dynamic, dynamic> dailyTaskTemp = {};

    if (widget.date == '' || widget.date == null) {
      dateTemp = Conversions.dateToString(DateTime.now().toUtc());
      postDataTemp = await postService.getDailyPost();
      dailyTaskTemp = await taskService.getDailyTask();
    } else {
      dateTemp = widget.date!;
      postDataTemp = await postService.getDailyPost(date: widget.date!);
      dailyTaskTemp = await taskService.getDailyTask(date: widget.date!);
    }

    if (!mounted) return;
    setState(() {
      userId = userService.getUserUID();
      postData = postDataTemp;
      date = dateTemp;
      dailyTask = dailyTaskTemp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: init,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt_rounded, size: 25),
                      SizedBox(width: 10),
                      Text(
                        dailyTask!['title'],
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TaskPage(taskTitle: dailyTask!['title']),
                      ),
                    ),
                    child: Text(
                      'Learn more about this SDG here!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  SizedBox(height: 10),
                  postData.isEmpty
                      ? Text('You have no post for this date!')
                      : Post(
                          postData: postData,
                          userId: userId!,
                          isEditable: false,
                        ),
                  Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Divider(),
                  ),
                  FriendsPosts(date: date, isEditable: widget.isEditable),
                ],
              ),
      ),
    );
  }
}
