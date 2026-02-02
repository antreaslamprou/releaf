import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiController.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'app.dart';

void main() async {
  // Ensures Firebase initializes first
  WidgetsFlutterBinding.ensureInitialized();
  // This config crashes the application, if the options is missing, it is fine
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCK53tyeHjONnKmlOcOYsaLAPoItMrTX8I",
      appId: "releaf-e2afa",
      messagingSenderId: "97602229252",
      projectId: "releaf-e2afa",
      databaseURL:
          "https://releaf-e2afa-default-rtdb.europe-west1.firebasedatabase.app",
      storageBucket: "releaf-e2afa.appspot.com",
    ),
  );

  // Initializes the custom avatars controller
  Get.put(FluttermojiController());

  // Run app wrapped in the providers values
  runApp(
    MultiProvider(
      // Create all providers
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TextScaleProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => DailyPostProvider()),
        ChangeNotifierProvider(create: (_) => UserDetailsProvider()),
      ],
      child: const App(),
    ),
  );
}
