import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/avatar_widget.dart';
import 'package:releaf/components/bottom_modal.dart';
import 'package:releaf/components/edit_avatar.dart';
import 'package:releaf/components/edit_data.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'package:releaf/services/user_service.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
        label: 'Edit Avatar',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                TemplateSinglePage(title: 'Edit Avatar', body: EditAvatar()),
          ),
        ),
      ),
      BottomAction(
        icon: Icons.upload,
        label: 'Upload Image',
        onTap: () {
          context.read<AvatarProvider>().uploadAvatarImage();
          context.read<UserDetailsProvider>().trigger();
        },
      ),
      BottomAction(
        icon: Icons.delete,
        label: 'Delete Image',
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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarWidget(
                key: ValueKey(context.watch<AvatarProvider>().avatarImage),
                avatarType: context.watch<AvatarProvider>().avatarType,
                avatarImage: context.watch<AvatarProvider>().avatarImage,
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
              Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TemplateSinglePage(
                        title: 'Edit Full Name',
                        body: EditData(page: 'Full Name'),
                      ),
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
                      builder: (_) => const TemplateSinglePage(
                        title: 'Edit Username',
                        body: EditData(page: 'Username'),
                      ),
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
                      builder: (_) => const TemplateSinglePage(
                        title: 'Edit Email',
                        body: EditData(page: 'Email'),
                      ),
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
                      builder: (_) => const TemplateSinglePage(
                        title: 'Edit Password',
                        body: EditData(page: 'Password'),
                      ),
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
    );
  }
}
