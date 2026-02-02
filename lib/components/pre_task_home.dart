import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/countdown_timer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:releaf/components/task.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/components/suggest_task.dart';
import 'package:releaf/services/api_service.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class PreTaskHome extends StatefulWidget {
  const PreTaskHome({super.key});

  @override
  State<PreTaskHome> createState() => _PreTaskHomeState();
}

class _PreTaskHomeState extends State<PreTaskHome> {
  // Get important user defined services for fetching/altering post and task data
  final _postService = PostService();
  final _taskService = TaskService();
  final _apiService = ApiService();

  // Data holders
  Map<dynamic, dynamic>? dailyTask;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late TextEditingController _postDescriptionController;
  String imageErrorMessage = '';
  bool isPosting = false;

  // Initialize the text controller and get the daily task
  @override
  void initState() {
    super.initState();

    _postDescriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDailyTask();
    });
  }

  // Dispose the text controller
  @override
  void dispose() {
    _postDescriptionController.dispose();

    super.dispose();
  }

  // Fetches the daily task
  Future<void> getDailyTask() async {
    final dailyTaskTemp = await _taskService.getDailyTask();

    if (!mounted) return;
    setState(() {
      dailyTask = dailyTaskTemp;
    });
  }

  // Open Camera
  Future<void> _openCamera() async {
    final XFile? cameraImage = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (cameraImage == null) return;
    setState(() {
      _image = File(cameraImage.path);
    });
  }

  // Removes the saved image
  void _deleteImage() {
    setState(() {
      _image = null;
    });
    Snackbar.show(context, 'Image deleted.');
  }

  // Creates a post using the saved image and the provided description, on
  // submit the buttons become null and there is a loader showing on the submit
  // button
  void _submitImage() async {
    setState(() {
      isPosting = true;
    });

    final apiText = await _apiService.analyzeImage(_image!);
    final isOkay = apiText.split(' - ')[0];

    if (isOkay == 'False') {
      setState(() {
        imageErrorMessage = apiText.split(' - ')[1];
      });

      return;
    }

    String message = await _postService.createPost(
      _image!,
      _postDescriptionController.text.trim(),
    );

    if (message.contains('Error')) {
      if (!mounted) return;
      Snackbar.show(context, message);

      setState(() {
        isPosting = false;
      });
    } else {
      setState(() {
        _image = null;
      });

      if (!mounted) return;
      context.read<DailyPostProvider>().completeDailyPost();

      if (!mounted) return;
      Snackbar.show(context, message);
    }
  }

  // When the image is not valid and the user needs to retake it
  void reset() {
    setState(() {
      isPosting = false;
      imageErrorMessage = '';
    });

    _openCamera();
  }

  // Shows a loader till the daily task is fetched, on take image button click,
  // the camera opens and after the user selects the image, they see the image,
  // the description text field and the cancel and submit buttons for the post.
  // The widget change happends depending on wether an image is saved to the
  // local variable or not.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: dailyTask == null
          ? const CircularProgressIndicator() // Page is loading
          : isPosting
          ? Center(
              // Post is being checked by AI
              child: Column(
                children: [
                  Text(
                    'We are checking the quality of the uploaded photo. You will be automatically re-directed to your fresh post in a few moments.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  imageErrorMessage.isEmpty
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Text(
                              imageErrorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: reset,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Retry'),
                                  SizedBox(width: 5),
                                  Icon(Icons.refresh),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            )
          : _image == null
          ? Column(
              // Home page pre task with timer
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/${dailyTask!['sdg_id']}.png',
                  width: 150,
                  height: 150,
                ),
                Text(
                  dailyTask!['sdg'],
                  textAlign: TextAlign.center,
                  style: context.text.titleSmall,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pending_actions_rounded, size: 25),
                    SizedBox(width: 10),
                    Text(dailyTask!['title'], style: context.text.titleSmall),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TemplateSinglePage(
                        title: 'Task ${Conversions.getNowString()}',
                        body: Task(
                          taskTitle: dailyTask!['title'],
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
                SizedBox(height: 10),
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
                Text(
                  'Complete the daily task by capturing an image using the camera! Press the camera button below to get started.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                CountdownTimer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onPressed: _openCamera,
                    child: Icon(Icons.camera_alt, size: 30),
                  ),
                ),
              ],
            )
          : Column(
              // Page with post image and description
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.file(_image!, width: 300, height: 300),
                SizedBox(height: 20),
                TextField(
                  controller: _postDescriptionController,
                  decoration: InputDecoration(
                    hintText: "Anything to share with your friends?",
                    labelText: 'Add Description',
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: isPosting ? null : _deleteImage,
                      child: Row(
                        children: [
                          Icon(Icons.clear_rounded),
                          SizedBox(width: 5),
                          Text('CANCEL'),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: isPosting ? null : _submitImage,
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded),
                          SizedBox(width: 5),
                          Text('POST'),
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
