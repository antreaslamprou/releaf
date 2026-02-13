import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/task.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/components/suggest_task.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class TaskHome extends StatelessWidget {
  const TaskHome({super.key, required this.task, this.isPosted = true});

  final Map<dynamic, dynamic> task;
  final bool isPosted;

  // Shows the home page data of the task icon, sdg, task, button suggest task,
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/${task['sdg_id']}.png',
          width: 150,
          height: 150,
        ),
        Text(
          task['sdg'],
          textAlign: TextAlign.center,
          style: context.text.titleSmall,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions_rounded, size: 25),
            SizedBox(width: 10),
            Text(task['title'], style: context.text.titleSmall),
          ],
        ),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TemplateSinglePage(
                title: 'Suggest a Task',
                body: SuggestTask(),
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.read<ThemeProvider>().primaryColor,
            foregroundColor:
                context.read<ThemeProvider>().brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Grow ReLeaf Impact\nSuggest a new challenge!',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 15),
        if (!isPosted)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              'Complete the daily task by capturing an image using the camera! Press the camera button below to get started.',
              textAlign: TextAlign.center,
            ),
          ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TemplateSinglePage(
                title: 'Task ${Conversions.getNowString()}',
                body: Task(
                  taskTitle: task['title'],
                  date: Conversions.getNowString(),
                ),
              ),
            ),
          ),
          child: Text(
            'Learn more about this task & SDG here!',
            style: context.text.labelMedium,
          ),
        ),
      ],
    );
  }
}
