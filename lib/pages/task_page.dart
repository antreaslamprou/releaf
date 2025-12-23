import 'package:flutter/material.dart';
import 'package:releaf/services/stats_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.taskTitle, required this.date});

  final String taskTitle;
  final String date;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final taskService = TaskService();
  final statsService = StatsService();

  late Map<dynamic, dynamic> task;
  late int totalLikes;
  late int totalPosts;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  void getData() async {
    final taskTemp = await taskService.getTaskByTitle(widget.taskTitle);
    final totalLikesTemp = await statsService.getTotalLikes(widget.date);
    final totalPostsTemp = await statsService.getTotalPosts(widget.date);

    setState(() {
      task = taskTemp;
      totalLikes = totalLikesTemp;
      totalPosts = totalPostsTemp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task ${widget.date}', style: context.text.titleSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15, 35, 15, 0),
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, color: Colors.red),
                        SizedBox(width: 5),
                        Text('$totalLikes'),
                        SizedBox(width: 20),
                        Icon(Icons.task_alt_rounded),
                        SizedBox(width: 5),
                        Text('$totalPosts'),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
