import 'package:flutter/material.dart';
import 'package:releaf/components/friend_widget.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class OutgoingFriendRequests extends StatefulWidget {
  const OutgoingFriendRequests({super.key, required this.backFunction});

  // Function to show the parent widget
  final VoidCallback backFunction;

  @override
  State<OutgoingFriendRequests> createState() => _OutgoingFriendRequestsState();
}

class _OutgoingFriendRequestsState extends State<OutgoingFriendRequests> {
  // Get important user defined services for fetching/altering friend requests
  final _friendRequestService = FriendRequestService();

  // Data holder and state variable
  List<dynamic> _outgoing = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOutgoingRequests();
    });
  }

  // Fetches friend requests sent from current user
  Future<void> getOutgoingRequests() async {
    final requestsList = await _friendRequestService.getOutgoingFriendRequest();

    if (requestsList.isEmpty) {
      setState(() {
        _outgoing = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      _outgoing = requestsList;
      isLoading = false;
    });
  }

  // Deletes a friend request, and then refetches the outgoind requests
  void removeOutgoingRequest(String receiverId) async {
    await _friendRequestService.deleteRequest(receiverId: receiverId);
    getOutgoingRequests();
    if (!mounted) return;
    Snackbar.show(context, 'Friend request cancelled!');
  }

  // Once the requests are fetched, the loader is removed and depending on
  // wether there are outgoing requests or not a message or the requests
  // will be shown
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getOutgoingRequests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.backFunction,
                icon: Icon(Icons.arrow_back),
              ),
              Text('Outgoing Requests', style: context.text.titleSmall),
            ],
          ),
          isLoading
              ? const CircularProgressIndicator()
              : _outgoing.isEmpty
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Text('No outgoing friend requests'),
                      SizedBox(height: 400),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _outgoing.length,
                  itemBuilder: (context, index) {
                    final request = _outgoing[index];
                    return FriendWidget(
                      key: ValueKey(request),
                      userUID: request,
                      type: 'Out',
                      onButtonClick: () => removeOutgoingRequest(request),
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
