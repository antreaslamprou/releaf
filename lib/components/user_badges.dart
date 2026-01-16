import 'package:flutter/material.dart';
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
    final List<Map<dynamic, dynamic>> badgesList = [
      {'title': 'A'},
      {'title': 'B'},
      {'title': 'C'},
      {'title': 'A'},
      {'title': 'B'},
      {'title': 'C'},
    ];
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
            padding: const EdgeInsets.all(16),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 20,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final item = badges[index];
              return Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Image.asset(
                        'assets/images/badge.png',
                        color: const Color.fromARGB(255, 255, 215, 0),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(item['title']),
                  ],
                ),
              );
            },
          );
  }
}
