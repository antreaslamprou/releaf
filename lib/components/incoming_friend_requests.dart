import 'package:flutter/material.dart';
import 'package:releaf/components/friend_widget.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class IncomingFriendRequests extends StatefulWidget {
  const IncomingFriendRequests({super.key, required this.backFunction});

  final VoidCallback backFunction;

  @override
  State<IncomingFriendRequests> createState() => _IncomingFriendRequestsState();
}

class _IncomingFriendRequestsState extends State<IncomingFriendRequests> {
  final userService = UserService();
  final friendRequestService = FriendRequestService();

  List<dynamic> _incoming = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getIncomingRequests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getIncomingRequests();
  }

  Future<void> getIncomingRequests() async {
    final requestsList = await friendRequestService.getIncomingFriendRequest();

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

  void removeIncoming(String senderId, {bool showSnackbar = true}) async {
    await friendRequestService.cancelOutgoingRequest(senderId: senderId);
    getIncomingRequests();
    if (showSnackbar && mounted) {
      Snackbar.show(context, 'Friend request rejected!');
    }
  }

  void acceptIncoming(String senderId) async {
    final isOkay = await userService.addFriend(senderId);
    if (!mounted) return;
    if (isOkay) {
      removeIncoming(senderId, showSnackbar: false);
      Snackbar.show(context, 'Friend added!');
    } else {
      Snackbar.show(context, 'Could not add friend!');
    }
  }

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
