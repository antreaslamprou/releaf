import 'package:flutter/material.dart';
import 'package:releaf/components/friends_posts.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/pages/task_page.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class PostTaskHome extends StatefulWidget {
  const PostTaskHome({super.key, this.date, this.isEditable = true});

  // Widget parameters used to fetch correctly the post data from a data and to
  // show/hide post actions
  final String? date;
  final bool isEditable;

  @override
  State<PostTaskHome> createState() => _PostTaskHomeState();
}

class _PostTaskHomeState extends State<PostTaskHome> {
  // Get important user defined services for fetching/altering post and task data
  PostService postService = PostService();
  TaskService taskService = TaskService();

  // Data holders and state variables
  Map<String, dynamic> postData = {};
  Map<dynamic, dynamic>? dailyTask;
  var date = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  // Fetches all data regarding the current user post and the task
  Future<void> init() async {
    String dateTemp = '';
    Map<String, dynamic> postDataTemp = {};
    Map<dynamic, dynamic> dailyTaskTemp = {};

    if (widget.date == '' || widget.date == null) {
      dateTemp = Conversions.getNowString();
      postDataTemp = await postService.getDailyPost();
      dailyTaskTemp = await taskService.getDailyTask();
    } else {
      dateTemp = widget.date!;
      postDataTemp = await postService.getDailyPost(date: widget.date!);
      dailyTaskTemp = await taskService.getDailyTask(date: widget.date!);
    }

    if (!mounted) return;
    setState(() {
      date = dateTemp;
      postData = postDataTemp;
      dailyTask = dailyTaskTemp;
      isLoading = false;
    });
  }

  // Shows the after completion task page, which has the daily task on top, the
  // current user's post and then their friends posts
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
                      Text(dailyTask!['title'], style: context.text.titleSmall),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskPage(
                          taskTitle: dailyTask!['title'],
                          date: Conversions.getNowString(),
                        ),
                      ),
                    ),
                    child: Text(
                      'Learn more about this SDG here!',
                      style: context.text.labelMedium,
                    ),
                  ),
                  SizedBox(height: 10),
                  postData.isEmpty
                      ? Text('You have no post for this date!')
                      : Post(postData: postData, isEditable: false),
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
