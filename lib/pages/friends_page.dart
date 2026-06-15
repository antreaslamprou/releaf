import 'package:flutter/material.dart';
import 'package:releaf/components/add_friend.dart';
import 'package:releaf/components/friend_list.dart';
import 'package:releaf/components/incoming_friend_requests.dart';
import 'package:releaf/components/outgoing_friend_requests.dart';
import 'package:releaf/extensions/text_theme_x.dart';

enum _FriendsView { list, add, requests }

enum _RequestsTab { incoming, outgoing }

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  _FriendsView _view = _FriendsView.list;
  Set<_RequestsTab> _selectedTab = {_RequestsTab.incoming};

  void _goTo(_FriendsView view) => setState(() => _view = view);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: switch (_view) {
        _FriendsView.list => Column(
          children: [
            Wrap(
              children: [
                OutlinedButton(
                  onPressed: () => _goTo(_FriendsView.add),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1, size: 18),
                      SizedBox(width: 6),
                      Text('Add Friend'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _goTo(_FriendsView.requests),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Requests'),
                ),
              ],
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('Friend List', style: context.text.titleSmall),
            ),

            const Expanded(child: FriendList()),
          ],
        ),

        _FriendsView.add => AddFriend(
          backFunction: () => _goTo(_FriendsView.list),
        ),

        _FriendsView.requests => Column(
          children: [
            Center(
              child: SegmentedButton<_RequestsTab>(
                segments: const [
                  ButtonSegment(
                    value: _RequestsTab.incoming,
                    label: Text('Incoming'),
                    icon: Icon(Icons.mark_email_unread),
                  ),
                  ButtonSegment(
                    value: _RequestsTab.outgoing,
                    label: Text('Outgoing'),
                    icon: Icon(Icons.outbox_outlined),
                  ),
                ],
                selected: _selectedTab,
                onSelectionChanged: (selection) =>
                    setState(() => _selectedTab = selection),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _selectedTab.contains(_RequestsTab.incoming)
                  ? IncomingFriendRequests(
                      backFunction: () => _goTo(_FriendsView.list),
                    )
                  : OutgoingFriendRequests(
                      backFunction: () => _goTo(_FriendsView.list),
                    ),
            ),
          ],
        ),
      },
    );
  }
}
