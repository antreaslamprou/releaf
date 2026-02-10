import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/avatar_widget.dart';
import 'package:releaf/components/bottom_modal.dart';
import 'package:releaf/components/friend_list.dart';
import 'package:releaf/components/full_modal.dart';
import 'package:releaf/components/posts_grid.dart';
import 'package:releaf/components/user_badges.dart';
import 'package:releaf/components/edit_profile.dart';
import 'package:releaf/components/saved_posts.dart';
import 'package:releaf/components/suggested_tasks.dart';
import 'package:releaf/pages/splash_page.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
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
  Map<String, dynamic>? userPosts;
  int totalPosts = 0;
  num totalBadges = 0;
  bool isCurrentUser = true;
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
    final isCurrentUserTemp =
        widget.userId == null || widget.userId == _userService.getUserUID();
    final data = isCurrentUserTemp
        ? await _userService.getUserData()
        : await _userService.getUserData(uid: widget.userId!);

    final postsNumber = await _postService.getTotalPosts(uid: widget.userId);
    final badgesNumber = await _userService.getTotalBadges(uid: widget.userId);

    // Check if add friend button should appear
    final friends = await _userService.getFriends();
    final canBeAdded = !isCurrentUserTemp && !friends.contains(widget.userId);

    final outgoing = await _friendRequestService.getOutgoingFriendRequest();
    final isOutgoing = canBeAdded && outgoing.contains(widget.userId);

    final incoming = await _friendRequestService.getIncomingFriendRequest();
    final isIncoming = canBeAdded && incoming.contains(widget.userId);

    // User Posts
    final posts = await _postService.getPosts(uid: widget.userId);

    setState(() {
      isCurrentUser = isCurrentUserTemp;
      isFriendable = canBeAdded;
      isOutgoingPending = isOutgoing;
      isIncomingPending = isIncoming;
      userData = data;
      totalPosts = postsNumber;
      totalBadges = badgesNumber;
      isLoading = false;
      userPosts = posts;
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SplashPage()),
        (route) => false,
      );
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
        icon: Icons.create,
        label: 'Edit Profile',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                TemplateSinglePage(title: 'Edit Profile', body: EditProfile()),
          ),
        ),
      ),
      BottomAction(
        icon: Icons.logout_rounded,
        label: 'Logout',
        onTap: () => showFullModal(
          context,
          'Logout',
          'Are you sure you want to logout from your account?',
          'Logout',
          () => logout(),
          isConfirmRed: true,
        ),
      ),
      BottomAction(
        icon: Icons.delete,
        label: 'Delete Account',
        onTap: () => showFullModal(
          context,
          'Delete Account',
          'Are you sure you want to delete your account?\nThis action cannot be reverted.',
          'Delete',
          () => deleteAccount(),
          isConfirmRed: true,
        ),
        isRed: true,
      ),
    ];

    showBottomActions(context, actions);
  }

  // Deletes all user related data and resets the providers
  void deleteAccount() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SplashPage(deleteUser: true)),
      (route) => false,
    );
  }

  // Show the profile page which contains the current user data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? null
          : AppBar(
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
                  // Current User Profile
                  isCurrentUser
                      ? IconButton(
                          onPressed: () => openMore(context),
                          icon: Icon(Icons.menu_rounded, size: 25),
                        )
                      // Outgoing Request User Profile
                      : isOutgoingPending
                      ? IconButton(
                          onPressed: () => showFullModal(
                            context,
                            'Remove Friend Request',
                            'Are you sure you want to delete the friend request to @${userData!['username']}?',
                            'Remove',
                            () => cancelOutgoingRequest(),
                            isConfirmRed: true,
                          ),
                          icon: Icon(Icons.cancel_rounded),
                        )
                      // Incoming Request User Profile
                      : isIncomingPending
                      ? Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: GestureDetector(
                                onTap: () => showFullModal(
                                  context,
                                  'Accept Friend Request',
                                  'Are you sure you want accept the friend request from @${userData!['username']}?',
                                  'Accept',
                                  () => acceptIncomingRequest(),
                                ),
                                child: Icon(Icons.check_circle_rounded),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: GestureDetector(
                                onTap: () => showFullModal(
                                  context,
                                  'Reject Friend Request',
                                  'Are you sure you want reject the friend request from @${userData!['username']}?',
                                  'Reject',
                                  () => cancelIncomingRequest(),
                                  isConfirmRed: true,
                                ),
                                child: Icon(Icons.cancel_rounded),
                              ),
                            ),
                          ],
                        )
                      // No Relation User Profile
                      : isFriendable
                      ? IconButton(
                          onPressed: addFriend,
                          icon: Icon(Icons.person_add_rounded),
                        )
                      // Friend Profile
                      : IconButton(
                          onPressed: () => showFullModal(
                            context,
                            'Remove Friend',
                            'Are you sure you want to remove @${userData!['username']} from your friends list?',
                            'Unfriend',
                            () => unfriend(),
                            isConfirmRed: true,
                          ),
                          icon: Icon(Icons.person_off),
                        ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarWidget(
                    key: ValueKey(
                      isCurrentUser
                          ? context.watch<AvatarProvider>().avatarImage
                          : userData!['avatar'],
                    ),
                    avatarType: isCurrentUser
                        ? context.watch<AvatarProvider>().avatarType
                        : userData!['avatar_type'],
                    avatarImage: isCurrentUser
                        ? context.watch<AvatarProvider>().avatarImage
                        : userData!['avatar'],
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
                        onTap: () {},
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
                                isPage: true,
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
                              body: UserBadges(userId: widget.userId),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              totalBadges.toString(),
                              style: context.text.titleSmall,
                            ),
                            Text('Badges'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 15),
                    child: Divider(),
                  ),
                  PostsGrid(posts: userPosts, isReportable: !isCurrentUser),
                ],
              ),
            ),
    );
  }
}
