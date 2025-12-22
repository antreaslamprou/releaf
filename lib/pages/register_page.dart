import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool isLoading = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              'avatar': Conversions.getDefaultAvatarBase(),
              'full_name': _nameController.text.trim(),
              'username': _usernameController.text.trim().toLowerCase(),
              'hotstreaks': 0,
              'points': 0,
              'last_post': '',
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

  Future<void> checkUsername(String value) async {
    UserService userService = UserService();

    if (value.isEmpty) {
      setState(() => _usernameError = 'Please enter a username');
      return;
    }

    bool usernameIsAvailable = await userService.checkUsernameAvailability(
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
                    const Text(
                      'ReLeaf',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: Validators.validateName,
                            decoration: InputDecoration(labelText: 'Full Name'),
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
                          ElevatedButton(
                            onPressed: handleRegister,
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Already a member? Log in here!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
