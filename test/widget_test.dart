import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/constants/app_constants.dart';
import 'package:rentflow/main.dart';

void main() {
  testWidgets('RentFlow app shell launches and displays brand info',
      (WidgetTester tester) async {
    // Build the RentFlow app and trigger a frame.
    await tester.pumpWidget(const RentFlowApp());

    // Verify that the application title appears.
    expect(find.text(AppConstants.appName), findsWidgets);

    // Verify that squad and sprint status are visible on the home shell.
    expect(find.text(AppConstants.squadNumber), findsOneWidget);
    expect(find.text(AppConstants.campusName), findsOneWidget);
  });
}
