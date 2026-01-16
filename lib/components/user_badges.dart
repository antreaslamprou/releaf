import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/services/sdgs_service.dart';
// import 'package:releaf/services/user_service.dart';

class UserBadges extends StatefulWidget {
  const UserBadges({super.key, this.userId});

  final String? userId;

  @override
  State<UserBadges> createState() => _UserBadgesState();
}

class _UserBadgesState extends State<UserBadges> {
  // Get important user defined services for fetching/altering user and post data
  // final _userService = UserService();
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
    // final userUID = widget.userId ?? _userService.getUserUID();
    final badgesMap = await _sdgsService.getSDGS();
    List<Map<dynamic, dynamic>> badgesList = [];
    badgesMap.forEach((key, value) => badgesList.add({'title': value}));

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
              childAspectRatio: 0.70,
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
                          // color: item['value'] >= 3
                          //     ? const Color.fromARGB(255, 255, 215, 0)
                          //     : item['value'] == 2
                          //     ? const Color.fromARGB(255, 192, 192, 192)
                          //     : item['value'] == 1
                          //     ? const Color.fromARGB(255, 205, 127, 50)
                          //     : Colors.grey[700],
                          color: Colors.grey[700],
                          fit: BoxFit.cover,
                        ),
                        Text(
                          '${index + 1}',
                          style: context.text.titleLarge?.copyWith(
                            fontFamily: 'Roboto',
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
                      'Complete the task to achieve the badge and proceed to the next one!',
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
