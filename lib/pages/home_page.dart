import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/post_task_home.dart';
import 'package:releaf/components/pre_task_home.dart';
import 'package:releaf/providers/daily_post_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: context.watch<DailyPostProvider>().isDailyPosted
          ? PostTaskHome()
          : PreTaskHome(),
    );
  }
}
