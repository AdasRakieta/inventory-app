import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ok_mobile_app/app_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Example app test', () {
    testWidgets('Tap on Login button', (tester) async {
      await tester.pumpWidget(AppWidget());

      expect(find.text('Waiting for auth'), findsOneWidget);

      final loginButton = find.byKey(
        const ValueKey('auth_screen_login_button'),
      );

      await tester.tap(loginButton);

      await tester.pump();

      expect(
        find.byKey(const ValueKey('auth_screen_progress_indicator')),
        findsOneWidget,
      );
    });
  });
}
