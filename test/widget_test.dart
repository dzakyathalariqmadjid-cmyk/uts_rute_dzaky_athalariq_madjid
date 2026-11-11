
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uts_maps_dzaky_athalariq_madjid/screens/home_screen.dart';

void main() {
  testWidgets(
    'Smart Logistics Routing dapat dibuka',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(
        find.text('Smart Logistics Routing'),
        findsOneWidget,
      );
    },
  );
}
