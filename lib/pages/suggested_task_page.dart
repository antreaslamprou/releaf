import 'package:flutter/material.dart';
import 'package:releaf/pages/suggest_task_page.dart';
import 'package:releaf/services/sdgs_service.dart';
import 'package:releaf/services/suggested_task_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class SuggestedTaskPage extends StatefulWidget {
  const SuggestedTaskPage({super.key});

  @override
  State<SuggestedTaskPage> createState() => _SuggestedTaskPageState();
}

class _SuggestedTaskPageState extends State<SuggestedTaskPage> {
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
    final isChanged = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SuggestTaskPage()));

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
    return Scaffold(
      appBar: AppBar(
        title: Text('My Suggestions', style: context.text.titleSmall),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    sdgs[task['sdg']],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
      ),
    );
  }
}
