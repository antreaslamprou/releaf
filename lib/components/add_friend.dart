import 'package:flutter/material.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key, required this.backFunction});

  // Function to show the parent widget
  final VoidCallback backFunction;

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  // Get important user defined services for fetching/altering user data and
  // friend requests
  final _userService = UserService();
  final _friendRequestService = FriendRequestService();

  // Data holders
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;

  // Initializes the text controller
  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
  }

  // Dispose the text controller
  @override
  void dispose() {
    _usernameController.dispose();

    super.dispose();
  }

  // Creates the friend request between the current user and the user with the
  // username provided in the text field
  void createFriendRequest() async {
    if (_formKey.currentState!.validate()) {
      final usernameNotValid = await _userService.checkUsernameAvailability(
        _usernameController.text,
      );

      if (!mounted) return;
      if (usernameNotValid) {
        Snackbar.show(context, 'No user found with this username!');
        return;
      }

      final status = await _friendRequestService.sendFriendRequest(
        _usernameController.text,
      );

      if (!mounted) return;
      switch (status) {
        case 'same-user':
          Snackbar.show(context, 'Cannot add yourself as a friend!');
          return;
        case 'existing-friend':
          Snackbar.show(context, 'User is already in your friend list!');
          return;
        case 'existing-request':
          Snackbar.show(context, 'Request already sent!');
          return;
        case 'pending-incoming-request':
          Snackbar.show(
            context,
            'There is a pending incoming reques from that user!',
          );
          return;
        case 'ok':
          setState(() {
            _usernameController.clear();
          });
          Snackbar.show(context, 'Friend request sent!');
          return;
        case _:
          Snackbar.show(context, 'Error with adding friend!');
          return;
      }
    }
  }

  // Shows the add friend page
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.backFunction,
              icon: Icon(Icons.arrow_back),
            ),
            Text('Add Friend', style: context.text.titleSmall),
          ],
        ),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 20),
          child: Text(
            'Please enter below the username of the user you wish to send a friend request to.',
          ),
        ),
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _usernameController,
                  validator: Validators.validateUsername,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorMaxLines: 3,
                    suffixIcon: IconButton(
                      onPressed: createFriendRequest,
                      icon: Icon(Icons.add, size: 30),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
      ],
    );
  }
}
