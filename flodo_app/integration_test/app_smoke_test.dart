import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flodo_app/main.dart' as app;

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Finder not found within timeout: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('android create task flow', (tester) async {
    final uniqueTitle =
        'Android QA Task ${DateTime.now().millisecondsSinceEpoch}';

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _pumpUntil(tester, find.text('Flodo'));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await _pumpUntil(tester, find.text('New Task'));

    final titleField = find.byType(TextField).first;
    final descriptionField = find.byType(TextField).at(1);

    await tester.enterText(titleField, uniqueTitle);
    await tester.enterText(descriptionField, 'Created from emulator integration test');
    await tester.pump();

    await tester.tap(find.text('Select due date *'));
    await tester.pumpAndSettle();

    final okButton = find.text('OK');
    if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton.last);
      await tester.pumpAndSettle();
    } else {
      final confirmButton = find.text('Confirm');
      await tester.tap(confirmButton.last);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Save Task'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await _pumpUntil(tester, find.text(uniqueTitle));
    expect(find.text(uniqueTitle), findsOneWidget);
  });
}
