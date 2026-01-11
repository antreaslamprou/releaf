import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Data holders and state variables
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  String? _usernameError;
  bool isLoading = false;

  // Initialize all text controllers
  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  // Dispose all text controllers
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // Function called on register, to check all fields are valid, register user
  // and navigate them to the login it insert their credentials to log in
  void handleRegister() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        await FirebaseDatabase.instance
            .ref("users/${userCredential.user!.uid}")
            .set({
              'id': userCredential.user!.uid,
              'avatar': Conversions.getDefaultAvatarBase(),
              'full_name': _nameController.text.trim(),
              'username': _usernameController.text.trim().toLowerCase(),
              'hotstreaks': 0,
              'points': 0,
              'last_post': '2000-01-01',
              'text_scale': 1,
              'is_dark_mode': false,
            });

        if (!mounted) return;
        Snackbar.show(context, 'Register Successful!');

        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseException catch (e) {
        Snackbar.show(context, 'Register Failed: ${e.message}');
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

  // Shows the register page which consist of the register form, on submit a
  // loader appears till the page changes or the error message appears
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text('ReLeaf', style: context.text.titleMedium),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: Validators.validateName,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              errorMaxLines: 2,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _usernameController,
                            validator: Validators.validateUsername,
                            onChanged: checkUsername,
                            decoration: InputDecoration(
                              errorText: _usernameError,
                              labelText: 'Username',
                              errorMaxLines: 3,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            validator: Validators.validateEmail,
                            decoration: InputDecoration(labelText: 'Email'),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            decoration: InputDecoration(labelText: 'Password'),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            controller: _confirmPasswordController,
                            validator: (value) =>
                                Validators.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                            ),
                          ),
                          SizedBox(height: 20),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: handleRegister,
                              child: const Text('REGISTER'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Already a member? Log in here!',
                        style: context.text.labelMedium,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
