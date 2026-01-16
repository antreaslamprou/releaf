import 'package:flutter/material.dart';
import 'package:releaf/components/suggest_task.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/services/sdgs_service.dart';
import 'package:releaf/services/suggested_task_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class SuggestedTasks extends StatefulWidget {
  const SuggestedTasks({super.key});

  @override
  State<SuggestedTasks> createState() => _SuggestedTasksState();
}

class _SuggestedTasksState extends State<SuggestedTasks> {
  // Get important user defined services for fetching/altering suggested tasks
  final _suggestedTaskService = SuggestedTaskService();
  final _sdgsService = SdgsService();

  // Data holders and state variables
  late List<Map<dynamic, dynamic>> tasks;
  late Map<dynamic, dynamic> sdgs;
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
    final tasksList = await _suggestedTaskService.getSuggestedTasks();
    final sdgsMap = await _sdgsService.getSDGS();

    // Remove the map keys, so that widgets can iterate easier
    List<Map<dynamic, dynamic>> tasksTemp = [];
    for (final task in tasksList) {
      task.forEach((key, value) {
        tasksTemp.add(Map<String, dynamic>.from(value));
      });
    }

    setState(() {
      tasks = tasksTemp;
      sdgs = sdgsMap;
      isLoading = false;
    });
  }

  void goTo() async {
    final isChanged = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TemplateSinglePage(
          title: 'Suggest a Task',
          body: SuggestTask(),
        ),
      ),
    );

    if (isChanged) getData();
  }

  Widget _goToGestureLink() {
    return GestureDetector(
      onTap: goTo,
      child: Text(
        tasks.isEmpty ? 'Suggest a task here!' : 'Suggest another task here!',
        style: context.text.labelMedium,
      ),
    );
  }

  // If its loading show loader or if the task didnt return anything show
  // an error message, otherwise show the task page with the data
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : tasks.isEmpty
            ? Column(
                children: [
                  Text('You have not suggested any tasks yet.'),
                  SizedBox(height: 20),
                  _goToGestureLink(),
                ],
              )
            : Column(
                spacing: 25,
                children: [
                  ...tasks.map(
                    (task) =>
                        Column(
                              children: [
                                Text(
                                  task['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  sdgs[task['sdg']],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text(task['description']),
                                SizedBox(height: 5),
                                Text('Status: ${task['status']}'),
                              ],
                            )
                            as Widget,
                  ),
                  _goToGestureLink(),
                ],
              ),
      ),
    );
  }
}
