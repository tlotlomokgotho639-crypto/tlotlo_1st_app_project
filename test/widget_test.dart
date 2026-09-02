import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tlotlo_1st_app_project/main.dart';

void main() {
  testWidgets('Pulse app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseApp());

    expect(find.text('Your sound,\nyour space.'), findsOneWidget);
    expect(find.text('Your library'), findsOneWidget);
  });

  testWidgets('App has music controls', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseApp());

    expect(find.text('Midnight Drive'), findsAtLeast(1));
    expect(find.byIcon(Icons.play_arrow), findsAtLeast(1));
    expect(find.byTooltip('Import music'), findsOneWidget);
  });
}