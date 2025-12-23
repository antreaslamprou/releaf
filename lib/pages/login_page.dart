import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        Snackbar.show(context, 'Login Successful!');

        Navigator.pushReplacementNamed(context, '/splash');
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
                            decoration: InputDecoration(labelText: 'Email'),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            decoration: InputDecoration(labelText: 'Password'),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: handleLogin,
                            child: Text('Log in'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
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
