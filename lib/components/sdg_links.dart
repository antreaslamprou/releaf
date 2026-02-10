import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:releaf/components/badge_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SdgLinks extends StatelessWidget {
  const SdgLinks({super.key});

  // Opens the sdg link
  Future<void> openLink(BuildContext context, int sdgNo) async {
    final url = 'https://sdgs.un.org/goals/goal$sdgNo';

    if (kIsWeb) {
      final uri = Uri.parse(url);
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(url)),
            ),
          ),
        ),
      );
    }
  }

  // Shows the user badges if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 17,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => openLink(context, index + 1),
            child: BadgeWidget(number: index + 1),
          ),
        );
      },
    );
  }
}
