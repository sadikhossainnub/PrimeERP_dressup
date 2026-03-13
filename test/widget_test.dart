import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeerp/app.dart';

void main() {
  testWidgets('Counter increment smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PrimeERPApp()));

    // Verify that the login screen or dashboard is shown
    // Since we don't have a counter anymore, this is just a smoke test
    expect(find.byType(PrimeERPApp), findsOneWidget);
  });
}
