import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class ApplicationMission extends StatelessWidget {
  const ApplicationMission({super.key});

  // Shows the application mission page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Mission', style: context.text.titleSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 15),
              Text(
                'Problem',
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Divider(),
              SizedBox(height: 5),
              Text(
                'The world faces escalating environmental degradation driven by climate change, biodiversity loss, and pollution, while progress toward the UN 17 Sustainable Development Goals is increasingly falling behind due to insufficient action, uneven implementation, and growing global inequalities.',
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 25),
              Text(
                'Mission',
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Divider(),
              SizedBox(height: 5),
              Text(
                'Social media platforms are being used heavily worldwide, shaping how people communicate, learn, and make everyday decisions. A social media platform that promotes sustainability could leverage this influence to encourage more sustainable behavior among its users by raising awareness, sharing actions, and normalizing eco-friendly choices.',
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 25),
              Text(
                'Gamification',
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Divider(),
              SizedBox(height: 5),
              Text(
                'Gamification keeps users engaged by incorporating leaderboards, hot streaks, daily tasks, and customization, which motivate users through competition, consistency, and personal expression.',
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
