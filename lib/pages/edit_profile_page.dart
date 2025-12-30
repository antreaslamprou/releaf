import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/pages/edit_data_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Data holders
  Map<String, dynamic>? userData;
  bool isUpdated = false;
  String userEmail = 'username@email.com';

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
    final email = _userService.getUserEmail().toString();

    setState(() {
      userData = data;
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

  // Navigates to the edit data page and if any change on data is done, the
  // current page refreshes the data
  Future<void> goToEdit(String page) async {
    final updated = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditDataPage(page: page)));

    if (updated == true) {
      isUpdated = true;
      loadData();
    }
  }

  // Show the edit profile page with the current user data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: context.text.titleSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(isUpdated),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
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
                Expanded(
                  child: GestureDetector(
                    onTap: () => goToEdit('Full Name'),
                    child: ListTile(
                      title: Text(userData?['full_name'] ?? 'Full Name'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () => goToEdit('Username'),
                    child: ListTile(
                      title: Text(userData?['username'] ?? '@Username'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 50),
                Expanded(
                  child: GestureDetector(
                    onTap: () => goToEdit('Email'),
                    child: ListTile(
                      title: Text(userEmail),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 25),
                Expanded(
                  child: GestureDetector(
                    onTap: () => goToEdit('Password'),
                    child: ListTile(
                      title: Text('**********'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
