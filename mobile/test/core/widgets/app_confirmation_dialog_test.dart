import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/core/widgets/app_confirmation_dialog.dart';

void main() {
  testWidgets('confirmation dialog renders and cancel returns false', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    result = await showAppConfirmationDialog(
                      context: context,
                      title: 'Discard changes?',
                      message: 'Your unsaved changes will be lost.',
                      cancelLabel: 'Keep Editing',
                      confirmLabel: 'Discard',
                      destructive: true,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.text('Keep Editing'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Keep Editing'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.text('Discard changes?'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmation dialog confirm returns true', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    result = await showAppConfirmationDialog(
                      context: context,
                      title: 'Delete budget?',
                      message: 'This budget will be removed.',
                      cancelLabel: 'Cancel',
                      confirmLabel: 'Delete',
                      destructive: true,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Delete budget?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
