import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/avatar_widget.dart';
import 'package:releaf/pages/profile_page.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/user_details_provider.dart';
import 'package:releaf/services/user_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Used to update the user data automatically once the user is updated
  late final UserDetailsProvider _triggerProvider;

  // Data holder
  List<Map<dynamic, dynamic>>? _leaderboard;

  @override
  void initState() {
    super.initState();

    // Creates a listener to update the user data once the user is updated
    _triggerProvider = context.read<UserDetailsProvider>();
    _triggerProvider.addListener(getData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      updateDailyPost();
    });
  }

  @override
  void dispose() {
    // Removes the listener once the widget is destroyed
    _triggerProvider.removeListener(updateDailyPost);

    super.dispose();
  }

  // Fetches the leaderboard data
  Future<void> getData() async {
    final leaderboard = await _userService.getLeaderboard();

    if (!mounted) return;
    setState(() {
      _leaderboard = leaderboard;
    });
  }

  // If the user posts for the day, the leaderboard will refetch the data
  void updateDailyPost() {
    final provider = context.read<DailyPostProvider>();

    void listener() {
      getData();

      provider.removeListener(listener);
    }

    provider.addListener(listener);
  }

  // Shows the leaderboard page
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getData,
      child: _leaderboard == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
              shrinkWrap: true,
              itemCount: _leaderboard!.length,
              itemBuilder: (context, index) {
                final user = _leaderboard![index];
                return Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 15),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(userId: user["id"]),
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              size: 30,
                              Icons.circle,
                              color: index + 1 == 1
                                  ? const Color.fromARGB(255, 255, 215, 0)
                                  : index + 1 == 2
                                  ? const Color.fromARGB(255, 192, 192, 192)
                                  : index + 1 == 3
                                  ? const Color.fromARGB(255, 205, 127, 50)
                                  : const Color.fromARGB(0, 0, 0, 0),
                            ),
                            Positioned(
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: index + 1 >= 1 && index + 1 <= 3
                                        ? Colors.black
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        AvatarWidget(
                          avatarType: user['avatar_type'],
                          avatarImage: user['avatar'],
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Text(user['username']),
                        SizedBox(width: 20),
                        Icon(Icons.local_fire_department),
                        const SizedBox(width: 2),
                        Text(user['hotstreaks'].toString()),
                        const Spacer(),
                        Text(user['points'].toString()),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.grey),
            ),
    );
  }
}
