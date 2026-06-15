import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:releaf/pages/register_page.dart';
import 'package:releaf/pages/splash_page.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';
import 'package:releaf/extensions/text_theme_x.dart';

import '../utils/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Data holders and state variables
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool isLoading = false;
  bool _obscurePassword = true;

  // Initialize all text controllers
  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  // Dispose all text controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // Function called on login, to check all fields are valid, login the user
  // and navigate them to the splash screen (which will take them to home)
  void handleLogin() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => SplashPage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          Snackbar.show(
            context,
            'Login Failed: The email or the password is incorrect.',
          );
        } else {
          Snackbar.show(context, 'Login Failed: ${e.message}');
        }
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

  // Shows the login page which consist of the login form, on submit a
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
                            controller: _emailController,
                            validator: Validators.validateEmail,
                            decoration: inputDecoration(label: "Email address", icon: Icons.email, hint: "Enter your email address").copyWith(
                              filled: false
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: _obscurePassword,
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            decoration: inputDecoration(label: "Password", icon: Icons.lock, hint: "Enter your password").copyWith(
                              filled: false,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: handleLogin,
                              child: Text('LOG IN'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      ),
                      child: Text(
                        'New to ReLeaf? Register here!',
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
