import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/show_bottom_actions.dart';
import 'package:releaf/pages/saved_posts_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
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
  final userService = UserService();
  final postService = PostService();

  Map<String, dynamic>? userData;
  int totalPosts = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  void loadData() async {
    final data = await userService.getUserData();
    final postsNumber = await postService.getTotalPosts();

    setState(() {
      userData = data;
      totalPosts = postsNumber;
    });
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');

      Snackbar.show(context, 'Logged out successfully.');
    } catch (e) {
      Snackbar.show(context, 'Error With Logging Out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Profile', style: context.text.titleSmall),
            Spacer(),
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
        padding: EdgeInsets.fromLTRB(20, 35, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: context
                      .watch<AvatarProvider>()
                      .imageProvider,
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: CircleAvatar(
                    radius: 19,
                    child: IconButton(
                      icon: const Icon(Icons.create),
                      onPressed: () => showBottomActions(
                        context,
                        onEdit: Provider.of<AvatarProvider>(
                          context,
                          listen: false,
                        ).uploadAvatar,
                        onDelete: Provider.of<AvatarProvider>(
                          context,
                          listen: false,
                        ).deleteAvatar,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 55),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(userData?['full_name'] ?? 'User'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(userData?['username'] ?? '@Username'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  userService.getUserEmail().toString() != ''
                      ? userService.getUserEmail().toString()
                      : 'N/A',
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hot Streaks',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(userData?['hotstreaks'].toString() ?? '0'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Posts', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(totalPosts.toString()),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Friends', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(((userData?['friends'] as Map?)?.length ?? 0).toString()),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Points', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(userData?['points'].toString() ?? '0'),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.black,
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
