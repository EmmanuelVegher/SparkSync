import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparksync/main.dart';
import 'package:sparksync/services/game_state.dart';

void main() {
  testWidgets('SparkSync app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SparkSyncApp());
    await tester.pump();

    // Advance past SplashScreen (1500ms timer + 600ms transition)
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 800));

    // Verify Auth screen appears
    expect(find.text('SparkSync'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);

    // Switch to Sign In mode so guest entry enters MainShell directly
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Scroll and Tap Skip to Guest Baller
    final guestBtn = find.byKey(const Key('guest_baller_btn'));
    expect(guestBtn, findsOneWidget);
    await tester.ensureVisible(guestBtn);
    await tester.tap(guestBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    // Verify navigation bar labels in MainShell (3 Ultra-Clean Apple Tabs)
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);

    // Stop timer to cleanly finish test
    GameState().stopTimer();
  });
}
