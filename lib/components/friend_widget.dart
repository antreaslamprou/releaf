import 'package:flutter/material.dart';
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

  // Widget parameters used to show and connect this widget with data and
  // functionality
  final String userUID;
  final String type;
  final VoidCallback onButtonClick;
  final VoidCallback? onExtraButtonClick;

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  // Get important user defined services for fetching/altering user data
  final UserService _userService = UserService();

  // Data holders and state variables
  String? avatar;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // Fetches the user data
  void loadData() async {
    Map<String, dynamic>? userData = await _userService.getUserDataById(
      widget.userUID,
    );

    if (userData.isEmpty) return;

    setState(() {
      avatar = userData['avatar'];
      username = userData['username'];
      isLoading = false;
    });
  }

  // Once the user data are fetched, the user widget used in lists is available
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
