import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nafas_os/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('onboarding renders Nafas OS thesis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );

    expect(find.text('Nafas OS'), findsOneWidget);
    expect(find.textContaining('يسبق الرغبة'), findsOneWidget);
  });
}
