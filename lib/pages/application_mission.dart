import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class ApplicationMission extends StatelessWidget {
  const ApplicationMission({super.key});

  // Shows the application mission page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Mission', style: context.text.titleSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 15),
            Text(
              'Mission',
              style: context.text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'If you want to continue, please connect to the internet first and try again!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
