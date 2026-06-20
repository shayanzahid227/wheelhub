import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheelhub/main.dart';

void main() {
  testWidgets('wheelHub splash shows brand name', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': true,
      'is_logged_in': true,
      'current_user':
          '{"id":"1","fullName":"Shayan","email":"shayan@gmail.com","phoneNumber":"+1 555-0142"}',
    });

    await tester.pumpWidget(const WheelHubApp());
    await tester.pump();

    expect(find.text('WheelHub'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
