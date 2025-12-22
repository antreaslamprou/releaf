import 'package:flutter/material.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class FriendWidget extends StatefulWidget {
  const FriendWidget({
    super.key,
    required this.userUID,
    required this.type,
    required this.onButtonClick,
    this.onExtraButtonClick,
  });

  final String userUID;
  final String type;
  final VoidCallback onButtonClick;
  final VoidCallback? onExtraButtonClick;

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  final UserService _userService = UserService();
  final friendRequestService = FriendRequestService();

  String? avatar;
  String? username;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
    Map<String, dynamic>? userData = await _userService.getUserDataById(
      widget.userUID,
    );

    if (userData == null) return;

    setState(() {
      avatar = userData['avatar'];
      username = userData['username'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 15, horizontal: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: MemoryImage(
              Conversions.baseToImage(
                isLoading ? Conversions.getDefaultAvatarBase() : avatar!,
              ),
            ),
          ),
          SizedBox(width: 15),
          Text(
            isLoading ? '' : username!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          widget.type == 'List'
              ? IconButton(
                  onPressed: widget.onButtonClick,
                  icon: Icon(Icons.person_off),
                )
              : widget.type == 'In'
              ? Row(
                  children: [
                    IconButton(
                      onPressed: widget.onButtonClick,
                      icon: Icon(Icons.check_circle_rounded),
                    ),
                    IconButton(
                      onPressed: widget.onExtraButtonClick,
                      icon: Icon(Icons.cancel_rounded),
                    ),
                  ],
                )
              : widget.type == 'Out'
              ? IconButton(
                  onPressed: widget.onButtonClick,
                  icon: Icon(Icons.cancel_rounded),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
