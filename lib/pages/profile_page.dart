import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/bottom_modal.dart';
import 'package:releaf/components/friend_list.dart';
import 'package:releaf/components/full_modal.dart';
import 'package:releaf/components/user_badges.dart';
import 'package:releaf/components/user_posts.dart';
import 'package:releaf/components/edit_profile.dart';
import 'package:releaf/components/saved_posts.dart';
import 'package:releaf/components/suggested_tasks.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();
  final _friendRequestService = FriendRequestService();

  // Used to update the user data automatically once the user is updated
  late final UserDetailsProvider _triggerProvider;

  // Data holders
  Map<String, dynamic>? userData;
  int totalPosts = 0;
  bool isFriend = false;
  bool isFriendable = false;
  bool isOutgoingPending = false;
  bool isIncomingPending = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Creates a listener to update the user data once the user is updated
    _triggerProvider = context.read<UserDetailsProvider>();
    _triggerProvider.addListener(loadData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void dispose() {
    // Removes the listener once the widget is destroyed
    _triggerProvider.removeListener(loadData);

    super.dispose();
  }

  // Loads the data for the current user
  void loadData() async {
    final isFriendTemp =
        widget.userId != null && widget.userId != _userService.getUserUID();
    final data = isFriendTemp
        ? await _userService.getUserDataById(widget.userId!)
        : await _userService.getUserData();

    final uid = widget.userId ?? _userService.getUserUID();
    final postsNumber = await _postService.getTotalPostsByUID(uid);

    // Check if add friend button should appear
    final friends = await _userService.getFriends();
    final canBeAdded = isFriendTemp && !friends.contains(widget.userId);

    final outgoing = await _friendRequestService.getOutgoingFriendRequest();
    final isOutgoing = canBeAdded && outgoing.contains(widget.userId);

    final incoming = await _friendRequestService.getIncomingFriendRequest();
    final isIncoming = canBeAdded && incoming.contains(widget.userId);

    setState(() {
      isFriend = isFriendTemp;
      isFriendable = canBeAdded;
      isOutgoingPending = isOutgoing;
      isIncomingPending = isIncoming;
      userData = data;
      totalPosts = postsNumber;
      isLoading = false;
    });
  }

  // Adds friend and updates UI
  void addFriend() async {
    await _friendRequestService.sendFriendRequest(userData!['username']);

    if (!mounted) return;
    Snackbar.show(context, 'Friend request sent!');

    setState(() {
      isFriendable = false;
      isOutgoingPending = true;
    });
  }

  // Cancel outgoing friend request and updates UI
  void cancelOutgoingRequest() async {
    await _friendRequestService.deleteRequest(receiverId: userData!['id']);

    if (!mounted) return;
    Snackbar.show(context, 'Friend request cancelled!');

    setState(() {
      isOutgoingPending = false;
    });
  }

  // Cancel outgoing friend request and updates UI
  void cancelIncomingRequest() async {
    await _friendRequestService.deleteRequest(senderId: userData!['id']);

    if (!mounted) return;
    Snackbar.show(context, 'Friend request cancelled!');

    setState(() {
      isIncomingPending = false;
    });
  }

  // Cancel outgoing friend request and updates UI
  void acceptIncomingRequest() async {
    await _friendRequestService.deleteRequest(senderId: userData!['id']);
    await _userService.addFriend(userData!['id']);

    if (!mounted) return;
    Snackbar.show(context, 'Friend request accepted!');

    setState(() {
      isIncomingPending = false;
      isFriendable = false;
    });
  }

  // Unfriend and update UI
  void unfriend() async {
    await _userService.removeFriend(userData!['id']);

    if (!mounted) return;
    Snackbar.show(context, 'Friend removed!');

    setState(() {
      isFriendable = true;
    });
  }

  // Resets the providers values and navigates to the splash screen to check if
  // there is any more proceedures (which will take user to login)
  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    } catch (e) {
      Snackbar.show(context, 'Error With Logging Out: $e');
    }
  }

  // Shows the bottom modal with information regarding the points system
  void showBottomModal(BuildContext context, {String? title, String? details}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15),
                Text(
                  title ?? 'Welcome to Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  details ??
                      'Here you can view different information regarding your profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Shows bottom modal for more profile options
  void openMore(BuildContext context) {
    final List<BottomAction> actions = [
      BottomAction(
        icon: Icons.bookmark_rounded,
        label: 'Saved Posts',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TemplateSinglePage(
              title: 'Saved Posts',
              body: SavedPosts(),
            ),
          ),
        ),
      ),
      BottomAction(
        icon: Icons.star_rounded,
        label: 'My Suggestions',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TemplateSinglePage(
              title: 'My Suggestions',
              body: SuggestedTasks(),
            ),
          ),
        ),
      ),
      BottomAction(
        icon: Icons.delete,
        label: 'Delete Account',
        onTap: showDeleteAccountDialog,
        isRed: true,
      ),
    ];

    showBottomActions(context, actions);
  }

  // Shows a dialog with the delete account warning, gives the option to proceed
  // or cancel
  Future<void> showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
                Text('This action cannot be reverted.'),
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
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  // Deletes all user related data and resets the providers
  void deleteAccount() async {
    final isOkay = await _userService.deleteUser();

    if (!mounted) return;
    if (!isOkay) return Snackbar.show(context, 'Error With Deleting Account');

    Snackbar.show(context, 'Account deleted.');
    logout();
  }

  // Show the profile page which contains the current user data
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Profile', style: context.text.titleSmall),
                  Spacer(),
                  GestureDetector(
                    onTap: () => showBottomModal(
                      context,
                      title: 'How to obtain hotstreak?',
                      details:
                          'Earn hotstreaks by posting daily and without missing a day. Each time you post while in a streak, the streak increases, boosting your total points.',
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department),
                        const SizedBox(width: 2),
                        Text(
                          userData?['hotstreaks'].toString() ?? '0',
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (!isFriend)
                    IconButton(
                      onPressed: () => openMore(context),
                      icon: Icon(Icons.menu_rounded, size: 25),
                    ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: isFriend
                        ? MemoryImage(
                            Conversions.baseToImage(
                              userData?['avatar'] ??
                                  Conversions.getDefaultAvatarBase(),
                            ),
                          )
                        : context.watch<AvatarProvider>().imageProvider,
                  ),
                  SizedBox(height: 25),
                  Text(
                    userData?['full_name'] ?? 'User',
                    style: context.text.titleSmall,
                  ),
                  Text('@${userData?['username'] ?? 'Username'}'),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TemplateSinglePage(
                              title: 'Posts',
                              body: UserPosts(userId: widget.userId),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              totalPosts.toString(),
                              style: context.text.titleSmall,
                            ),
                            Text('Posts'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showBottomModal(
                          context,
                          title: 'How to obtain points?',
                          details:
                              'Earn points by posting daily and achieving a hot streak. Each time you post, the points are calculated as stated below:\nTotal Points = Points + Hotstreaks + 1',
                        ),
                        child: Column(
                          children: [
                            Text(
                              userData?['points'].toString() ?? '0',
                              style: context.text.titleSmall,
                            ),
                            Text('Points'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TemplateSinglePage(
                              title: 'Friends',
                              body: FriendList(
                                userId: widget.userId,
                                isEditable: widget.userId == null,
                              ),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ((userData?['friends'] as Map?)?.length ?? 0)
                                  .toString(),
                              style: context.text.titleSmall,
                            ),
                            Text('Friends'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TemplateSinglePage(
                              title: 'Badges',
                              body: UserBadges(),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ((userData?['friends'] as Map?)?.length ?? 0)
                                  .toString(),
                              style: context.text.titleSmall,
                            ),
                            Text('Badges'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 15),
                    child: Divider(),
                  ),
                  !isFriend
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TemplateSinglePage(
                                    title: 'Edit Profile',
                                    body: EditProfile(),
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.create),
                                  SizedBox(width: 7),
                                  Text('EDIT PROFILE'),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: logout,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.black,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.logout_rounded),
                                  SizedBox(width: 5),
                                  Text('LOGOUT'),
                                ],
                              ),
                            ),
                          ],
                        )
                      : isOutgoingPending
                      ? Column(
                          children: [
                            Text('Pending Outgoing Friend Request'),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: cancelOutgoingRequest,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.close),
                                      SizedBox(width: 10),
                                      Text('CANCEL REQUEST'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : isIncomingPending
                      ? Column(
                          children: [
                            Text('Pending Incoming Friend Request'),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: acceptIncomingRequest,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_rounded),
                                      SizedBox(width: 10),
                                      Text('ACCEPT'),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: cancelIncomingRequest,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.close),
                                      SizedBox(width: 10),
                                      Text('CANCEL'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : isFriendable
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: addFriend,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person_add_rounded),
                                  SizedBox(width: 10),
                                  Text('ADD FRIEND'),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => showFullModal(
                                context,
                                'Remove Friend',
                                'Are you sure you want to remove this friend?\nThis action cannot be undone.',
                                'Unfriend',
                                () => unfriend(),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.black,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person_off),
                                  SizedBox(width: 10),
                                  Text('REMOVE FRIEND'),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
  }
}
