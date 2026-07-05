import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pharmacy_chain_fe/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PharmaCareApp());

    // Verify that the login screen is rendered (by checking for "Đăng nhập" text)
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
