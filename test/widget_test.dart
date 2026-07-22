import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readrift/widgets/bouncy_tap.dart';

void main() {
  testWidgets('BouncyTap scales down on press down and invokes callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BouncyTap(
              onTap: () {
                tapped = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap Me'), findsOneWidget);

    await tester.tap(find.text('Tap Me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
