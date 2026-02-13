// Opens the sdg link
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebLink {
  static Future<void> open(BuildContext context, String url) async {
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
}
