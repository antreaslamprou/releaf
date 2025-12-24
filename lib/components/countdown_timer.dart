import 'dart:async';
import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/utils/conversions.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  // Data holders
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();

    startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  // Starts the countdown timer and every second calls the update function
  void startCountdown() {
    updateRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateRemaining();
    });
  }

  // Checks for the remaining time and updates the timer
  void updateRemaining() {
    final now = Conversions.getNow();

    DateTime target = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }

    setState(() {
      _remaining = target.difference(now);
    });
  }

  // Shows the timer with a clear and readable format
  String formatRemaining(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes % 60)}:${two(duration.inSeconds % 60)}';
  }

  // Shows the remaining timer
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(formatRemaining(_remaining), style: context.text.titleLarge),
    );
  }
}
