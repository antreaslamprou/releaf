import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/pages/edit_profile_page.dart';
import 'package:releaf/pages/saved_posts_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();

  // Used to update the user data automatically once the user is updated
  late final UserDetailsProvider _triggerProvider;

  // Data holders
  Map<String, dynamic>? userData;
  int totalPosts = 0;

  @override
  void initState() {
    super.initState();

    // Creates a listener to update the user data once the user is updated
    _triggerProvider = context.read<UserDetailsProvider>();
    _triggerProvider.addListener(loadData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void dispose() {
    // Removes the listener once the widget is destroyed
    _triggerProvider.removeListener(loadData);

    super.dispose();
  }

  // Loads the data for the current user
  void loadData() async {
    final data = await _userService.getUserData();
    final postsNumber = await _postService.getTotalPosts();

    setState(() {
      userData = data;
      totalPosts = postsNumber;
    });
  }

  // Resets the providers values and navigates to the splash screen to check if
  // there is any more proceedures (which will take user to login)
  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);

      Snackbar.show(context, 'Logged out successfully.');
    } catch (e) {
      Snackbar.show(context, 'Error With Logging Out: $e');
    }
  }

  // Shows the bottom modal with information regarding the points system
  void showPointsDetails(
    BuildContext context, {
    String? title,
    String? details,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15),
                Text(
                  title ?? 'Welcome to Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  details ??
                      'Here you can view different information regarding your profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show the profile page which contains the current user data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Profile', style: context.text.titleSmall),
            Spacer(),
            GestureDetector(
              onTap: () => showPointsDetails(
                context,
                title: 'How to obtain hotstreak?',
                details:
                    'Earn hotstreaks by posting daily and without missing a day. Each time you post while in a streak, the streak increases.',
              ),
              child: Icon(Icons.local_fire_department),
            ),
            const SizedBox(width: 2),
            Text(
              userData?['hotstreaks'].toString() ?? '0',
              style: context.text.bodyMedium,
            ),
            IconButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SavedPostsPage())),
              icon: Icon(Icons.bookmark_rounded),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: context.watch<AvatarProvider>().imageProvider,
            ),
            SizedBox(height: 25),
            Text(
              userData?['full_name'] ?? 'User',
              style: context.text.titleSmall,
            ),
            Text('@${userData?['username'] ?? 'Username'}'),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(totalPosts.toString(), style: context.text.titleSmall),
                    Text('Posts'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      userData?['points'].toString() ?? '0',
                      style: context.text.titleSmall,
                    ),
                    Row(
                      children: [
                        Text('Points'),
                        GestureDetector(
                          onTap: () => showPointsDetails(
                            context,
                            title: 'How to obtain points?',
                            details:
                                'Earn points by posting daily and achieving a hot streak. Each time you post, the points are calculated as stated below:\nTotal Points = Points + Hotstreaks + 1',
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(5),
                            child: Icon(Icons.info_outline, size: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ((userData?['friends'] as Map?)?.length ?? 0).toString(),
                      style: context.text.titleSmall,
                    ),
                    Text('Friends'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => EditProfilePage())),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text('EDIT PROFILE'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('LOGOUT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
