import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  // Shows the application mission page
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: context.text.headlineSmall),
          Divider(),
          SizedBox(height: 5),
          Text(
            'Your privacy is important to us. This Privacy Policy explains how our application collects, uses, and deletes user data. By using the app, you agree to the practices described in this policy.',
          ),
          SizedBox(height: 25),
          Text('Personal Data Collection', style: context.text.headlineSmall),
          Divider(),
          SizedBox(height: 5),
          Text(
            'We do not collect personal data for any purpose other than those explicitly stated in this policy.\nNo personal data is collected, stored, or processed for advertising, analytics, tracking, or any other unrelated purpose.',
          ),
          SizedBox(height: 25),
          Text(
            'User Authentication and Profile Information',
            style: context.text.headlineSmall,
          ),
          Divider(),
          SizedBox(height: 5),
          Text(
            ''' 
We collect only the minimum information necessary to: 
    • Authenticate users
    • Create and maintain a user profile within the application.

This information is used solely for account functionality and user identification within the app and is not shared with third parties.''',
          ),
          SizedBox(height: 25),
          Text(
            'Images and User-Generated Content',
            style: context.text.headlineSmall,
          ),
          Divider(),
          SizedBox(height: 5),
          Text(
            '''
Any images or content posted by users are: 
    • Collected only for the purpose of being displayed within the application
    • Not analyzed, reused, sold, or processed for any other purpose.

We do not use user-uploaded images for training, marketing, or external distribution.''',
          ),
          SizedBox(height: 25),
          Text('Data Usage Limitations', style: context.text.headlineSmall),
          Divider(),
          SizedBox(height: 5),
          Text('''
User information, including profile data, images, posts, comments, and reports:
    • Is used only to support core application functionality
    • Is never used for marketing, advertising, or data profiling.'''),
          SizedBox(height: 25),
          Text(
            'Data Deletion and Account Removal',
            style: context.text.headlineSmall,
          ),
          Divider(),
          SizedBox(height: 5),
          Text('''
Users may delete their account at any time. Upon account deletion all user-related data will be permanently deleted. 

This includes: 
    • User profile information
    • User posts
    • User comments
    • User reports
    • Any other data associated with the user account.
  
Once deleted, this data cannot be recovered.'''),
          SizedBox(height: 25),
          Text('Data Security', style: context.text.headlineSmall),
          Divider(),
          SizedBox(height: 5),
          Text(
            'We take reasonable technical and organizational measures to protect user data from unauthorized access, loss, or misuse.',
          ),
          SizedBox(height: 25),
          Text('Changes to This Policy', style: context.text.headlineSmall),
          Divider(),
          SizedBox(height: 5),
          Text(
            'This Privacy Policy may be updated from time to time. Any changes will be reflected within the application. Continued use of the app after updates indicates acceptance of the revised policy.',
          ),
          SizedBox(height: 25),
          Text('Contact', style: context.text.headlineSmall),
          Divider(),
          SizedBox(height: 5),
          Text(
            'If you have any questions or concerns regarding this Privacy Policy or your data, you may contact us through the application.',
          ),
        ],
      ),
    );
  }
}
