import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/bottom_modal.dart';
import 'package:releaf/pages/edit_data_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
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

  // Used to update the user data automatically once the user is updated
  late final UserDetailsProvider _triggerProvider;

  // Data holders
  Map<String, dynamic>? userData;
  String userEmail = 'username@email.com';

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
    final email = _userService.getUserEmail().toString();

    setState(() {
      userData = data;
      userEmail = email;
    });
  }

  // Shows the bottom modal sheet when users click on the edit avatar, giving
  // them the options to edit the avatar, delete the avatar or cancel the actions
  void showBottomActionsModal(BuildContext context) {
    final List<BottomAction> actions = [
      BottomAction(
        icon: Icons.edit,
        label: 'Edit',
        onTap: () {
          context.read<AvatarProvider>().uploadAvatar();
          context.read<UserDetailsProvider>().trigger();
        },
      ),
      BottomAction(
        icon: Icons.delete,
        label: 'Delete',
        onTap: () {
          context.read<AvatarProvider>().deleteAvatar();
          context.read<UserDetailsProvider>().trigger();
        },
        isRed: true,
      ),
    ];

    showBottomActions(context, actions);
  }

  // Show the edit profile page with the current user data
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
                        onPressed: () => showBottomActionsModal(context),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditDataPage(page: 'Full Name'),
                      ),
                    ),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditDataPage(page: 'Username'),
                      ),
                    ),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditDataPage(page: 'Email'),
                      ),
                    ),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditDataPage(page: 'Password'),
                      ),
                    ),
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
