import 'package:flutter/material.dart';
import 'package:releaf/components/friend_widget.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  // Get important user defined services for fetching/altering post data
  final _userService = UserService();

  // Data holder and state variables
  List<dynamic> _friendList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFriends();
    });
  }

  // Fetches the friends
  Future<void> getFriends() async {
    final friendsList = await _userService.getFriends();

    setState(() {
      _friendList = friendsList;
      isLoading = false;
    });
  }

  // Shows a dialog with the unfriend warning, gives the option to proceed
  // or cancel
  Future<void> showUnfriendDialog(String friendId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Friend '),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to remove this friend?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                unfriend(friendId);
              },
            ),
          ],
        );
      },
    );
  }

  // Removed the friend from both the users
  void unfriend(String friendId) async {
    final isOkay = await _userService.removeFriend(friendId);

    if (!mounted) return;
    if (!isOkay) return Snackbar.show(context, 'Could not remove friend!');

    getFriends();
    return Snackbar.show(context, 'Friend removed!');
  }

  // Once the data are fetched, the loader is removed and a list of friends or a
  // message is shown depending on wether the current user has friends
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getFriends,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLoading
              ? const CircularProgressIndicator()
              : _friendList.isEmpty
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        children: [Text('You currently dont have any friends')],
                      ),
                      SizedBox(height: 400),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _friendList.length,
                  itemBuilder: (context, index) {
                    final request = _friendList[index];
                    return FriendWidget(
                      key: ValueKey(request),
                      userUID: request,
                      type: 'List',
                      onButtonClick: () => showUnfriendDialog(request),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Colors.grey),
                ),
        ],
      ),
    );
  }
}
