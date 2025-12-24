import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Data holder
  List<Map<dynamic, dynamic>>? _leaderboard;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      updateDailyPost();
    });
  }

  // Fetches the leaderboard data
  Future<void> getData() async {
    final leaderboard = await _userService.getLeaderboard();

    setState(() {
      _leaderboard = leaderboard;
    });
  }

  // If the user posts for the day, the leaderboard will refetch the data
  void updateDailyPost() {
    final provider = Provider.of<DailyPostProvider>(context, listen: false);

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
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: MemoryImage(
                          Conversions.baseToImage(user['avatar']),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(user['username']),
                      const Spacer(),
                      Text(user['points'].toString()),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.grey),
            ),
    );
  }
}
