import 'package:flutter/material.dart';
import 'package:releaf/components/friend_widget.dart';
import 'package:releaf/components/full_modal.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';

class FriendList extends StatefulWidget {
  const FriendList({
    super.key,
    this.userId,
    this.isEditable = true,
    this.isPage = false,
  });

  final String? userId;
  final bool isEditable;
  final bool isPage;

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
    final friendsList = await _userService.getFriends(uid: widget.userId);

    setState(() {
      _friendList = friendsList;
      isLoading = false;
    });
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
      child: Padding(
        padding: widget.isPage
            ? EdgeInsets.symmetric(horizontal: 15, vertical: 25)
            : EdgeInsetsGeometry.all(0),
        child: SizedBox.expand(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _friendList.isEmpty
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Text('You currently do not have any friends'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _friendList.length,
                  itemBuilder: (context, index) {
                    final friendId = _friendList[index];
                    return FriendWidget(
                      key: ValueKey(friendId),
                      userUID: friendId,
                      type: widget.isEditable ? 'List' : '',
                      onButtonClick: () => showFullModal(
                        context,
                        'Remove Friend',
                        'Are you sure you want to remove this friend?\nThis action cannot be undone.',
                        'Unfriend',
                        () => unfriend(friendId),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Colors.grey),
                ),
        ),
      ),
    );
  }
}
