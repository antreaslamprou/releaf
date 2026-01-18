import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/badge_widget.dart';
import 'package:releaf/providers/text_scale_provider.dart';
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
    final userData = await _userService.getUserData(uid: widget.userId);

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
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            shrinkWrap: true,
            itemCount: badges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 10,
              childAspectRatio:
                  0.7 / context.read<TextScaleProvider>().scaleFactor,
            ),
            itemBuilder: (context, index) {
              final item = badges[index];
              return Container(
                alignment: Alignment.center,
                child: BadgeWidget(
                  number: index + 1,
                  progress: item['progress'],
                  title: item['title'],
                ),
              );
            },
          );
  }
}
