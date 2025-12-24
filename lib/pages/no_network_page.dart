import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class NoNetworkPage extends StatelessWidget {
  const NoNetworkPage({super.key});

  // Shows the no network page and redirects to splash screen to check for
  // internet connection on refresh
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    'assets/images/prohibited.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text('Oopsie ...', style: context.text.headlineLarge),
            SizedBox(height: 5),
            Text(
              'Seems like you are not connected to the internet!',
              style: context.text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'If you want to continue, please connect to the internet first and try again!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/splash'),
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
      ),
    );
  }
}
