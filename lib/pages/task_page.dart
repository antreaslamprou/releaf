import 'package:flutter/material.dart';
import 'package:releaf/services/task_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.taskTitle});

  final String taskTitle;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final taskService = TaskService();
  late Map<dynamic, dynamic> task;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTask();
    });
  }

  void getTask() async {
    final taskTemp = await taskService.getTaskByTitle(widget.taskTitle);

    setState(() {
      task = taskTemp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      task['sdg'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(task['description'], textAlign: TextAlign.center),
                    SizedBox(height: 10),
                    Text(task['reflection'], textAlign: TextAlign.center),
                  ],
                ),
        ),
      ),
    );
  }
}
