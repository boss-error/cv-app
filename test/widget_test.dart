// This is a basic Flutter widget test for CV Generator App.

import 'package:flutter_test/flutter_test.dart';

import 'package:cv_generator_app/main.dart';

void main() {
  testWidgets('CV Generator App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CVGeneratorApp());

    // Verify that the splash screen loads
    expect(find.text('CV Generator'), findsOneWidget);
    expect(find.text('Professional CV Creation Made Easy'), findsOneWidget);
  });
}
