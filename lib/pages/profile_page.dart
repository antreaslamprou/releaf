import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();

  // Data holders
  Map<String, dynamic>? userData;
  String userEmail = 'username@email.com';
  int totalPosts = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // Loads the data for the current user
  void loadData() async {
    final data = await _userService.getUserData();
    final postsNumber = await _postService.getTotalPosts();
    final email = _userService.getUserEmail().toString();

    if (data['last_post'] == '2000-01-01') data['last_post'] = 'N/A';

    setState(() {
      userData = data;
      totalPosts = postsNumber;
      userEmail = email;
    });
  }

  // Shows the bottom modal sheet when users click on the edit avatar, giving
  // them the options to edit the avatar, delete the avatar or cancel the actions
  void showBottomActions(
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
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

  // Show the profile page which contains the current user data
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
                Text(userEmail),
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
                Text(
                  'Last Activity (UTC)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(userData?['last_post'] ?? 'N/A'),
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
