import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf/pages/login_page.dart';

void main() {
  testWidgets('Login page has email, password and login button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Check for widgets
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'LOGIN'), findsOneWidget);
  });
}
