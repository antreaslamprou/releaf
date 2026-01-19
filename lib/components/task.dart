import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/services/stats_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class Task extends StatefulWidget {
  const Task({super.key, required this.taskTitle, required this.date});

  final String taskTitle;
  final String date;

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  // Get important user defined services for fetching/altering user data and
  // total posts/stats
  final _taskService = TaskService();
  final _statsService = StatsService();

  // Data holders and state variables
  late Map<dynamic, dynamic> task;
  late int totalPosts;
  late int totalLikes;
  late int totalComments;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  // Fetches all task related data
  void getData() async {
    final taskTemp = await _taskService.getTaskByTitle(widget.taskTitle);
    final totalPostsTemp = await _statsService.getTotalPosts(widget.date);
    final totalLikesTemp = await _statsService.getTotalLikes(widget.date);
    final totalCommentsTemp = await _statsService.getTotalComments(widget.date);

    setState(() {
      task = taskTemp;
      totalPosts = totalPostsTemp;
      totalLikes = totalLikesTemp;
      totalComments = totalCommentsTemp;
      isLoading = false;
    });
  }

  // If its loading show loader or if the task didnt return anything show
  // an error message, otherwise show the task page with the data
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : task.isEmpty
            ? Text('Something went wrong!')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    task['title'],
                    textAlign: TextAlign.center,
                    style: context.text.titleSmall,
                  ),
                  SizedBox(height: 10),
                  Text(
                    task['sdg'],
                    textAlign: TextAlign.center,
                    style: context.text.titleSmall,
                  ),
                  SizedBox(height: 15),
                  Text(task['description'], textAlign: TextAlign.center),
                  SizedBox(height: 5),
                  Text(task['reflection'], textAlign: TextAlign.center),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt_rounded),
                      SizedBox(width: 5),
                      Text('$totalPosts'),
                      SizedBox(width: 30),
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(width: 5),
                      Text('$totalLikes'),
                      SizedBox(width: 30),
                      Icon(
                        Icons.comment,
                        color: context.read<ThemeProvider>().primaryColor,
                      ),
                      SizedBox(width: 5),
                      Text('$totalComments'),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
