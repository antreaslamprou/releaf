import 'package:flutter/material.dart';
import 'package:releaf/components/sdg_links.dart';
import 'package:releaf/services/sdgs_service.dart';
import 'package:releaf/services/suggested_task_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';

class SuggestTask extends StatefulWidget {
  const SuggestTask({super.key});

  @override
  State<SuggestTask> createState() => _SuggestTaskState();
}

class _SuggestTaskState extends State<SuggestTask> {
  // Get important user defined services for fetching/altering suggested tasks and sdgs
  final _suggestedTaskService = SuggestedTaskService();
  final _sdgsService = SdgsService();

  // Data holders and state variables
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<DropdownMenuItem<String>> dropdownOptions = [];
  String? selectedSdg;
  String? selectedSdgError;
  bool isPosted = false;
  bool isLoading = true;

  // Initialized the text controllers
  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSDGs();
    });
  }

  // Dispose the text controllers
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void getSDGs() async {
    final sdgsMap = await _sdgsService.getSDGS();
    if (!mounted) return;
    List<DropdownMenuItem<String>> finalOptions = [
      DropdownMenuItem(
        value: null,
        child: Text('Please choose an SDG', style: context.text.bodyMedium),
      ),
    ];
    sdgsMap.forEach(
      (key, value) => finalOptions.add(
        DropdownMenuItem(
          value: key,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 5),
            child: Row(
              children: [
                Image.asset('assets/images/$key.png', height: 50),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: context.text.bodyMedium,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    setState(() {
      dropdownOptions = finalOptions;
      isLoading = false;
    });
  }

  // Adds the post to the database if all data are valid
  void postTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await _suggestedTaskService.createSuggestedTasks(
        _titleController.text,
        selectedSdg!,
        _descriptionController.text,
      );

      if (!mounted) return;
      Snackbar.show(context, 'Task suggested, thank you!');

      setState(() {
        selectedSdg = null;
        _titleController.clear();
        _descriptionController.clear();
        isPosted = true;
        isLoading = false;
      });
    }
  }

  // If its loading show loader or if the task didnt return anything show
  // an error message, otherwise show the task page with the data
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Center(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Complete the information below regarding your idea and get 10 points once your task is approved!',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _titleController,
                      validator: Validators.validateNotEmpty,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'eg. Recycle a plastic bottle',
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      validator: Validators.validateNotEmpty,
                      decoration: InputDecoration(
                        labelText: 'Sustainable Development Goal',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      initialValue: selectedSdg,
                      items: dropdownOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedSdg = value;
                          selectedSdgError = null;
                        });
                      },
                    ),
                    if (selectedSdgError != null)
                      Text(
                        selectedSdgError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text:
                                'Want to learn more about each SDG? Access in browser ',
                          ),
                          TextSpan(
                            text: 'https://sdgs.un.org/goals',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' or tap on the links below!'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SdgLinks(),
                    TextFormField(
                      controller: _descriptionController,
                      validator: Validators.validateNotEmpty,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText:
                            'eg. Take an image of you recycling a plastic bottle',
                      ),
                    ),
                    SizedBox(height: 20),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ElevatedButton(
                        onPressed: postTask,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text('SUBMIT'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
