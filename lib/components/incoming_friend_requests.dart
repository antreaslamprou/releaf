import 'package:flutter/material.dart';
import 'package:releaf/components/friend_widget.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class IncomingFriendRequests extends StatefulWidget {
  const IncomingFriendRequests({super.key, required this.backFunction});

  // Function to show the parent widget
  final VoidCallback backFunction;

  @override
  State<IncomingFriendRequests> createState() => _IncomingFriendRequestsState();
}

class _IncomingFriendRequestsState extends State<IncomingFriendRequests> {
  // Get important user defined services for fetching/altering user data and
  // friend requests
  final _userService = UserService();
  final _friendRequestService = FriendRequestService();

  // Data holder and state variable
  List<dynamic> _incoming = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIncomingRequests();
    });
  }

  // Fetches friend requests received from current user
  Future<void> getIncomingRequests() async {
    final requestsList = await _friendRequestService.getIncomingFriendRequest();

    if (requestsList.isEmpty) {
      setState(() {
        _incoming = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      _incoming = requestsList;
      isLoading = false;
    });
  }

  // Deletes a friend request, and then refetches the incoming requests
  void removeIncoming(String senderId, {bool showSnackbar = true}) async {
    await _friendRequestService.deleteRequest(senderId: senderId);
    getIncomingRequests();
    if (showSnackbar && mounted) {
      Snackbar.show(context, 'Friend request rejected!');
    }
  }

  // Adds the friend in both users in the database and removes the friend request
  void acceptIncoming(String senderId) async {
    final isOkay = await _userService.addFriend(senderId);
    if (!mounted) return;
    if (isOkay) {
      removeIncoming(senderId, showSnackbar: false);
      Snackbar.show(context, 'Friend added!');
    } else {
      Snackbar.show(context, 'Could not add friend!');
    }
  }

  // Once the requests are fetched, the loader is removed and depending on
  // wether there are incoming requests or not a message or the requests
  // will be shown
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getIncomingRequests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.backFunction,
                icon: Icon(Icons.arrow_back),
              ),
              Text('Incoming Requests', style: context.text.titleSmall),
            ],
          ),
          isLoading
              ? const CircularProgressIndicator()
              : _incoming.isEmpty
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Text('No incoming friend requests'),
                      SizedBox(height: 400),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _incoming.length,
                  itemBuilder: (context, index) {
                    final request = _incoming[index];
                    return FriendWidget(
                      key: ValueKey(request),
                      userUID: request,
                      type: 'In',
                      onButtonClick: () => acceptIncoming(request),
                      onExtraButtonClick: () => removeIncoming(request),
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
