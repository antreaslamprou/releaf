import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/countdown_timer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:releaf/pages/task_page.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/utils/snackbar.dart';

class PreTaskHome extends StatefulWidget {
  const PreTaskHome({super.key});

  @override
  State<PreTaskHome> createState() => _PreTaskHomeState();
}

class _PreTaskHomeState extends State<PreTaskHome> {
  final postService = PostService();
  final taskService = TaskService();

  late TextEditingController _postDescriptionController;

  final ImagePicker _picker = ImagePicker();
  File? _image;

  Map<dynamic, dynamic>? dailyTask;

  @override
  void initState() {
    super.initState();

    _postDescriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDailyTask();
    });
  }

  Future<void> getDailyTask() async {
    final dailyTaskTemp = await taskService.getDailyTask();

    setState(() {
      dailyTask = dailyTaskTemp;
    });
  }

  // Open Camera
  Future<void> _openCamera() async {
    final XFile? cameraImage = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (cameraImage != null) {
      setState(() {
        _image = File(cameraImage.path);
      });

      if (!mounted) return;
      Snackbar.show(context, 'Image captured!');
    } else {
      if (!mounted) return;
      Snackbar.show(context, 'No image captured.');
    }
  }

  void _deleteImage() {
    setState(() {
      _image = null;
    });
    Snackbar.show(context, 'Image deleted.');
  }

  void _submitImage() async {
    String message = await postService.createPost(
      _image!,
      _postDescriptionController.text.trim(),
    );

    if (message.contains('Error')) {
      if (!mounted) return;
      Snackbar.show(context, message);
    } else {
      setState(() {
        _image = null;
      });

      if (!mounted) return;
      Provider.of<DailyPostProvider>(
        context,
        listen: false,
      ).completeDailyPost();

      if (!mounted) return;
      Snackbar.show(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: dailyTask == null
          ? const CircularProgressIndicator()
          : _image == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CountdownTimer(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pending_actions_rounded, size: 25),
                    SizedBox(width: 10),
                    Text(
                      dailyTask!['title'],
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskPage(taskTitle: dailyTask!['title']),
                    ),
                  ),
                  child: Text(
                    'Learn more about this SDG here!',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Complete the daily task by capturing an image using the camera! Press the camera button below to get started.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _openCamera,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Icon(Icons.camera_alt, size: 30),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.file(_image!, width: 300, height: 300),
                SizedBox(height: 20),
                TextField(
                  controller: _postDescriptionController,
                  decoration: InputDecoration(
                    hintText: "Anything to share with your friends?",
                    labelText: 'Post Description',
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _deleteImage,
                      child: Row(
                        children: [
                          Icon(Icons.clear_rounded),
                          SizedBox(width: 5),
                          Text('Cancel'),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _openCamera,
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded),
                          SizedBox(width: 5),
                          Text('Retake'),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitImage,
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded),
                          SizedBox(width: 5),
                          Text('Submit'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
