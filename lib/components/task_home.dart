import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/task.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/components/suggest_task.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/extensions/text_theme_x.dart';

import '../utils/user_image.dart';
import 'countdown_timer.dart';

class TaskHome extends StatefulWidget {
  const TaskHome({super.key, required this.task, this.isPosted = true});

  final Map<dynamic, dynamic> task;
  final bool isPosted;

  @override
  State<TaskHome> createState() => _TaskHomeState();
}

class _TaskHomeState extends State<TaskHome> {

  final ImagePicker _picker = ImagePicker();
  UserImage? _image;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;
    final isLight = themeProvider.brightness == Brightness.light;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 10),
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
                  'assets/images/${widget.task['sdg_id']}.png',
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
            if (!widget.isPosted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 150)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Complete the daily challenge by capturing a photo associated with today\'s Sustainability Development Goal before the countdown runs out. Press the camera button below to get started.',
                        style: context.text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),

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
                            widget.task['title'],
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
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TemplateSinglePage(
                            title: 'Task ${Conversions.getNowString()}',
                            body: Task(
                              taskTitle: widget.task['title'],
                              date: Conversions.getNowString(),
                            ),
                          ),
                        ),
                      ),
                      icon: Icon(Icons.chevron_right, color: primaryColor),
                      iconAlignment: IconAlignment.end,
                      label: Text(
                        'Learn more about this task & SDG',
                        style: context.text.labelMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            CountdownTimer(),
            Row(
              children: [
                Expanded(
                  child: Divider(color: primaryColor.withValues(alpha: 0.3)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black.withValues(alpha: 100)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    label: Text("Post your picture", style: TextStyle(fontSize: 20),),
                    onPressed: _openCamera,
                    icon: Icon(Icons.camera_alt, size: 30),
                  ),
                ),
                Expanded(
                  child: Divider(color: primaryColor.withValues(alpha: 0.3)),
                ),
              ],
            ),

            SizedBox(height: 15),

            Text(
              'GROW RELEAF IMPACT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 10),


            // Suggest Task CTA Button
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TemplateSinglePage(
                    title: 'Suggest a Task',
                    body: SuggestTask(),
                  ),
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: Icon(Icons.add_a_photo_outlined),
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 12,
                ),
              ),
              label: Text(
                'Suggest a new challenge!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open Camera
  Future<void> _openCamera() async {

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    final XFile? cameraImage = await _picker.pickImage(
      source: source,
    );
    if (cameraImage == null) return;

    if (kIsWeb) {
      final bytes = await cameraImage.readAsBytes();
      setState(() {
        _image = UserImage.web(bytes);
      });
    } else {
      setState(() {
        _image = UserImage.mobile(File(cameraImage.path));
      });
    }
  }
}
