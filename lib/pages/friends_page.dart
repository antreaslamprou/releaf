import 'package:flutter/material.dart';
import 'package:releaf/components/add_friend.dart';
import 'package:releaf/components/friend_list.dart';
import 'package:releaf/components/incoming_friend_requests.dart';
import 'package:releaf/components/outgoing_friend_requests.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  String _page = 'List';

  void setPage(String page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 10),
      child: _page == 'List'
          ? Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 5),
                    Text('Friend List', style: context.text.titleSmall),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: () => setPage('Add'),
                      icon: Icon(Icons.add_circle_outline_outlined),
                    ),
                    IconButton(
                      onPressed: () => setPage('In'),
                      icon: Icon(Icons.mark_email_unread_outlined),
                    ),
                    IconButton(
                      onPressed: () => setPage('Out'),
                      icon: Icon(Icons.forward_to_inbox),
                    ),
                  ],
                ),
                FriendList(),
              ],
            )
          : _page == 'Add'
          ? AddFriend(backFunction: () => setPage('List'))
          : _page == 'In'
          ? IncomingFriendRequests(backFunction: () => setPage('List'))
          : _page == 'Out'
          ? OutgoingFriendRequests(backFunction: () => setPage('List'))
          : Text('Something went wrong'),
    );
  }
}
