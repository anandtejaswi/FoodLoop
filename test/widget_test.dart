// ============================================================
// test/widget_test.dart  –  Basic app smoke test
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:foodloop_app/main.dart';

void main() {
  testWidgets('FoodLoop app smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const FoodLoopApp());
    // The splash screen should be visible initially
    expect(find.byType(FoodLoopApp), findsOneWidget);
  });
}
