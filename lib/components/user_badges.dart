import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/services/sdgs_service.dart';
import 'package:releaf/services/user_service.dart';

class UserBadges extends StatefulWidget {
  const UserBadges({super.key, this.userId});

  final String? userId;

  @override
  State<UserBadges> createState() => _UserBadgesState();
}

class _UserBadgesState extends State<UserBadges> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _sdgsService = SdgsService();

  // Data holders and state variables
  late List<Map<dynamic, dynamic>> badges;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // Loads the user saved badges
  void loadData() async {
    final userUID = widget.userId ?? _userService.getUserUID();
    final userData = await _userService.getUserDataById(userUID);

    final badgesMap = await _sdgsService.getSDGS();
    List<Map<dynamic, dynamic>> badgesList = [];
    badgesMap.forEach(
      (key, value) => badgesList.add({
        'id': key,
        'title': value,
        'progress': userData['badges'][key] ?? 0,
      }),
    );

    setState(() {
      badges = badgesList;
      isLoading = false;
    });
  }

  // Shows the user badges if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : GridView.builder(
            shrinkWrap: true,
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final item = badges[index];
              return Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/badge.png',
                          width: 115,
                          color: item['progress'] >= 3
                              ? const Color.fromARGB(255, 255, 215, 0)
                              : item['progress'] == 2
                              ? const Color.fromARGB(255, 192, 192, 192)
                              : item['progress'] == 1
                              ? const Color.fromARGB(255, 205, 127, 50)
                              : Colors.grey[700],
                          fit: BoxFit.cover,
                        ),
                        Text(
                          '${index + 1}',
                          style: context.text.titleLarge?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      item['progress'] == 0
                          ? 'Complete the task to achieve the badge!'
                          : item['progress'] == 1
                          ? 'Complete the task two times to achieve the badge'
                          : item['progress'] == 2
                          ? 'Complete the task three times to achieve the badge'
                          : 'You have gathered all badges for this type!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
