import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the search bar is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the app title or search hint is present
    expect(find.text('Search any city worldwide...'), findsOneWidget);
  });

  testWidgets('Search bar accepts input', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Find the text field
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text into the search field
    await tester.enterText(textField, 'Paris');

    // Verify the text was entered
    expect(find.text('Paris'), findsOneWidget);
  });
}
