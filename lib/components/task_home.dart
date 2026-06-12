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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;
    final isLight = themeProvider.brightness == Brightness.light;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SDG Image with decorative background
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
                Image.asset(
                  'assets/images/${task['sdg_id']}.png',
                  width: 140,
                  height: 140,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Text(
            //   task['sdg'].toString().toUpperCase(),
            //   textAlign: TextAlign.center,
            //   style: context.text.titleSmall?.copyWith(
            //     fontWeight: FontWeight.w900,
            //     letterSpacing: 1.2,
            //     color: primaryColor,
            //   ),
            // ),
            // Conditional Instruction Banner
            if (!isPosted)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined, color: Colors.amber),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Complete the daily task by capturing an image using the camera! Press the camera button below to get started.',
                        style: context.text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // const SizedBox(height: 10),

            // Task Detail Card
            Card(
              elevation: 0,
              color: isLight ? Colors.grey[50] : Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isLight ? Colors.grey[200]! : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [

                    Text(
                      "TODAY'S CHALLENGE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),

                    SizedBox(height: 10,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.pending_actions_rounded, color: primaryColor, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task['title'],
                            style: context.text.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          'Learn more about this task & SDG',
                          style: context.text.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Suggest Task CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TemplateSinglePage(
                      title: 'Suggest a Task',
                      body: SuggestTask(),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isLight ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'GROW RELEAF IMPACT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Suggest a new challenge!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
