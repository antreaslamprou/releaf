import 'package:flutter/material.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/validators.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key, required this.backFunction});

  final VoidCallback backFunction;

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final userService = UserService();
  final friendRequestService = FriendRequestService();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
  }

  void createFriendRequest() async {
    if (_formKey.currentState!.validate()) {
      final usernameNotValid = await userService.checkUsernameAvailability(
        _usernameController.text,
      );

      if (!mounted) return;
      if (usernameNotValid) {
        Snackbar.show(context, 'No user found with this username!');
        return;
      }

      final status = await friendRequestService.sendFriendRequest(
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
          Snackbar.show(context, 'Friend request sent!');
          return;
        case _:
          Snackbar.show(context, 'Error with adding friend!');
          return;
      }
    }
  }

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
            Text(
              'Add Friend',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
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
