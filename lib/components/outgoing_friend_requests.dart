import 'package:flutter/material.dart';
import 'package:releaf/components/friend_widget.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/snackbar.dart';

class OutgoingFriendRequests extends StatefulWidget {
  const OutgoingFriendRequests({super.key, required this.backFunction});

  final VoidCallback backFunction;

  @override
  State<OutgoingFriendRequests> createState() => _OutgoingFriendRequestsState();
}

class _OutgoingFriendRequestsState extends State<OutgoingFriendRequests> {
  final userService = UserService();
  final friendRequestService = FriendRequestService();

  List<dynamic> _outgoing = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getOutgoingRequests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getOutgoingRequests();
  }

  Future<void> getOutgoingRequests() async {
    final requestsList = await friendRequestService.getOutgoingFriendRequest();

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

  void removeOutgoingRequest(String receiverId) async {
    await friendRequestService.cancelOutgoingRequest(receiverId: receiverId);
    getOutgoingRequests();
    if (!mounted) return;
    Snackbar.show(context, 'Friend request cancelled!');
  }

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
              Text(
                'Outgoing Requests',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
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
