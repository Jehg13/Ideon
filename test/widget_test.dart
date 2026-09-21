import 'package:flutter_test/flutter_test.dart';

import 'package:ideon/main.dart';
import 'package:ideon/screens/onboarding_screen.dart';
import 'package:ideon/screens/splash_screen.dart';

void main() {
  testWidgets('starts on splash and navigates to onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
