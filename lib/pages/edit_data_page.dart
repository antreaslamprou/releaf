import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';

class EditDataPage extends StatefulWidget {
  const EditDataPage({super.key, required this.page});

  final String page;

  @override
  State<EditDataPage> createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();

  // Data holders
  Map<String, dynamic>? userData;
  String? _usernameError;
  bool emailMessage = false;
  bool isLoading = false;
  bool isUpdated = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstFieldController;
  late TextEditingController _secondFieldController;
  late TextEditingController _thirdFieldController;

  @override
  void initState() {
    super.initState();

    _firstFieldController = TextEditingController();
    _secondFieldController = TextEditingController();
    _thirdFieldController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void dispose() {
    _firstFieldController.dispose();
    _secondFieldController.dispose();
    _thirdFieldController.dispose();

    super.dispose();
  }

  // Loads the data for the current user
  void loadData() async {
    switch (widget.page) {
      case 'Full Name':
        final data = await _userService.getUserData();
        _firstFieldController.text = data['full_name'];
        return;
      case 'Username':
        final data = await _userService.getUserData();
        _firstFieldController.text = data['username'];
        return;
      case 'Email':
        _firstFieldController.text = _userService.getUserEmail().toString();
        return;
    }
  }

  // Checks the username on each character change in the username field,
  // informing the user if the currently inserted username is available
  Future<void> checkUsername(String value) async {
    if (value.isEmpty) {
      setState(() => _usernameError = 'Please enter a username');
      return;
    }

    bool usernameIsAvailable = await _userService.checkUsernameAvailability(
      value,
    );

    try {
      if (!usernameIsAvailable) {
        setState(() => _usernameError = 'Username "$value" is taken');
      } else {
        setState(() => _usernameError = null);
      }
    } catch (e) {
      setState(() => _usernameError = null);
    }
  }

  Future<void> handleSubmit() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        bool isOkay = false;
        switch (widget.page) {
          case 'Full Name':
            isOkay = await _userService.updateUserData(
              'full_name',
              _firstFieldController.text.trim(),
            );
            break;
          case 'Username':
            isOkay = await _userService.updateUserData(
              'username',
              _firstFieldController.text.trim(),
            );
            break;
          case 'Email':
            isOkay = await _userService.updateUserEmail(
              _firstFieldController.text.trim(),
            );
            setState(() => emailMessage = true);
            break;
          case 'Password':
            isOkay = await _userService.updateUserPassword(
              _secondFieldController.text.trim(),
            );
            if (isOkay) {
              _firstFieldController.clear();
              _secondFieldController.clear();
              _thirdFieldController.clear();
            }
            break;
        }
        isUpdated = isOkay;
        if (!mounted || widget.page == 'Email') return;
        Snackbar.show(context, '${widget.page} Updated Successfully!');
      } on FirebaseException catch (e) {
        Snackbar.show(context, 'Editing ${widget.page} Failed: ${e.message}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget saveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: ElevatedButton(
          onPressed: isLoading ? null : handleSubmit,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(),
                  ),
                )
              : Text('SAVE'),
        ),
      ),
    );
  }

  // Show the edit profile page with the current user data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.page}', style: context.text.titleSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(isUpdated),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: widget.page == 'Full Name'
            ? Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstFieldController,
                      validator: Validators.validateName,
                      decoration: InputDecoration(labelText: 'Full Name'),
                    ),
                    saveButton(),
                  ],
                ),
              )
            : widget.page == 'Username'
            ? Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstFieldController,
                      onChanged: checkUsername,
                      validator: Validators.validateUsername,
                      decoration: InputDecoration(
                        errorText: _usernameError,
                        labelText: 'Username',
                        errorMaxLines: 3,
                      ),
                    ),
                    saveButton(),
                  ],
                ),
              )
            : widget.page == 'Email'
            ? Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstFieldController,
                      validator: Validators.validateEmail,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    emailMessage
                        ? Column(
                            children: [
                              SizedBox(height: 15),
                              Text(
                                'An email has been sent to your new email address. To finish with the process, please click on the confirmation link in the email.',
                              ),
                            ],
                          )
                        : SizedBox(),
                    saveButton(),
                  ],
                ),
              )
            : widget.page == 'Password'
            ? Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      obscureText: true,
                      controller: _firstFieldController,
                      validator: Validators.validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      controller: _secondFieldController,
                      validator: Validators.validatePassword,
                      decoration: InputDecoration(labelText: 'New Password'),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      controller: _thirdFieldController,
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _secondFieldController.text,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                    ),
                    saveButton(),
                  ],
                ),
              )
            : Text('Something went wrong!'),
      ),
    );
  }
}
