import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();

  // Data holders
  Map<String, dynamic>? userData;
  String userEmail = 'username@email.com';
  int totalPosts = 0;

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: 'Full Name');
    _usernameController = TextEditingController(text: 'Username');
    _emailController = TextEditingController(text: 'user@email.com');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  // Loads the data for the current user
  void loadData() async {
    final data = await _userService.getUserData();
    final postsNumber = await _postService.getTotalPosts();
    final email = _userService.getUserEmail().toString();

    _nameController.text = data['full_name'] ?? '';
    _usernameController.text = data['username'] ?? 'Username';
    _emailController.text = email;

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

  // Show the profile page which contains the current user data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: context.text.titleSmall),
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
                  radius: 55,
                  backgroundImage: context
                      .watch<AvatarProvider>()
                      .imageProvider,
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: CircleAvatar(
                    radius: 18,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.create, size: 22),
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
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Expanded(child: TextField(controller: _nameController)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Expanded(child: TextField(controller: _usernameController)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Expanded(child: TextField(controller: _emailController)),
              ],
            ),
            SizedBox(height: 50),
            FractionallySizedBox(
              widthFactor: 1,
              child: ElevatedButton(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
