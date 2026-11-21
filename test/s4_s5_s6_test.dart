import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summah/main.dart';
import 'package:summah/screens/admin_sign_in_screen.dart';
import 'package:summah/screens/create_account_screen.dart';
import 'package:summah/screens/jumuah_screen.dart';
import 'package:summah/utils/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

final _createButton = find.widgetWithText(FilledButton, 'Create account');

void main() {
  testWidgets('S5 shows inline errors when submitted empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AdminSignInScreen()),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('S6 shows D1 dialog after a valid submission', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const CreateAccountScreen()),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alamin Bawa Idris');
    await tester.enterText(fields.at(1), 'alamin@sabanciuniv.edu');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');

    await tester.ensureVisible(_createButton);
    await tester.tap(_createButton);
    await tester.pumpAndSettle();

    expect(find.text('Demo account created'), findsOneWidget);
  });

  testWidgets('S6 reports mismatching passwords', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const CreateAccountScreen()),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'different1');

    await tester.ensureVisible(_createButton);
    await tester.tap(_createButton);
    await tester.pump();

    expect(find.text("Passwords don't match"), findsOneWidget);
  });

  testWidgets('S4 removes a Friday update card and Undo restores it',
      (tester) async {
    await tester.pumpWidget(_wrap(const JumuahScreen()));

    const title = "Arrive early for Jumu'ah";
    await tester.ensureVisible(find.text(title));
    expect(find.text(title), findsOneWidget);

    await tester.tap(find.byTooltip('Remove update').first);
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('App starts without errors', (tester) async {
    await tester.pumpWidget(const SummahApp());
    expect(find.text('SUmmah'), findsWidgets);
  });
}
