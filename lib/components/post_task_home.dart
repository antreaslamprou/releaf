import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/friends_posts.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/components/task_home.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/utils/conversions.dart';

class PostTaskHome extends StatefulWidget {
  const PostTaskHome({super.key, this.date});

  // Widget parameters used to fetch correctly the post data from a data
  final String? date;

  @override
  State<PostTaskHome> createState() => _PostTaskHomeState();
}

class _PostTaskHomeState extends State<PostTaskHome> {
  // Get important user defined services for fetching/altering post and task data
  final _postService = PostService();
  final _taskService = TaskService();

  // Used to update the user data automatically once the user is updated
  late final UserDetailsProvider _triggerProvider;

  // Data holders and state variables
  Map<String, dynamic> postData = {};
  Map<dynamic, dynamic>? dailyTask;
  var date = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Creates a listener to update the user data once the user is updated
    _triggerProvider = context.read<UserDetailsProvider>();
    _triggerProvider.addListener(updateDailyPost);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  @override
  void dispose() {
    // Removes the listener once the widget is destroyed
    _triggerProvider.removeListener(updateDailyPost);

    super.dispose();
  }

  // Fetches all data regarding the current user post and the task
  Future<void> init() async {
    String dateTemp = '';
    Map<String, dynamic> postDataTemp = {};
    Map<dynamic, dynamic> dailyTaskTemp = {};

    if (widget.date == '' || widget.date == null) {
      dateTemp = Conversions.getNowString();
      postDataTemp = await _postService.getDailyPost();
      dailyTaskTemp = await _taskService.getDailyTask();
    } else {
      dateTemp = widget.date!;
      postDataTemp = await _postService.getDailyPost(date: widget.date!);
      dailyTaskTemp = await _taskService.getDailyTask(date: widget.date!);
    }

    if (!mounted) return;
    setState(() {
      date = dateTemp;
      postData = postDataTemp;
      dailyTask = dailyTaskTemp;
      isLoading = false;
    });
  }

  // Updates the data for the current user's daily post
  void updateDailyPost() async {
    final postDataTemp = (widget.date == '' || widget.date == null)
        ? await _postService.getDailyPost()
        : await _postService.getDailyPost(date: widget.date!);
    setState(() {
      postData = postDataTemp;
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
                  TaskHome(task: dailyTask!, isPosted: true),
                  SizedBox(height: 15),
                  postData.isEmpty
                      ? Text('You have no post for this date!')
                      : Post(
                          key: UniqueKey(),
                          postData: postData,
                          isReportable: false,
                        ),
                  Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Divider(),
                  ),
                  FriendsPosts(key: UniqueKey(), date: date),
                ],
              ),
      ),
    );
  }
}
