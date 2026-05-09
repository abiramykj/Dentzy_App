// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dentzy/main.dart';
import 'package:dentzy/services/language_provider.dart';
import 'package:dentzy/services/settings_provider.dart';

void main() {
  testWidgets('Dentzy app widget test', (WidgetTester tester) async {
    // Create provider instances without full async initialization
    // to avoid test hangs
    final languageProvider = LanguageProvider();
    final settingsProvider = SettingsProvider();
    
    // Build our app and trigger a frame with the widgets
    await tester.pumpWidget(
      MyApp(
        languageProvider: languageProvider,
        settingsProvider: settingsProvider,
      ),
    );
    
    // Allow the widget tree to settle
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that the app is launched
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
