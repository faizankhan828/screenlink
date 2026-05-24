import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:screenlink/src/screens/auth/auth_gate_screen.dart';

void main() {
  testWidgets('SceneLink auth landing renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthGateScreen()));

    expect(find.text('SceneLink'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
