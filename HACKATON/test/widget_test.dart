// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DealerApp());

    // Verify that the app loads with the dashboard
    expect(find.text('Дилер Партнёр'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
