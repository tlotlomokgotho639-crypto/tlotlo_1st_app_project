import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tlotlo_1st_app_project/main.dart';

void main() {
  testWidgets('Study Planner app loads correctly', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const StudyPlannerApp());

    // Verify the app title appears
    expect(find.text('Study Planner'), findsOneWidget);
    
    // If you're using the simple one-file version with "Study Planner Pro":
    // expect(find.text('Study Planner Pro'), findsOneWidget);
  });

  testWidgets('App has add course button', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyPlannerApp());
    
    // Check for add button or related text
    expect(find.byIcon(Icons.add), findsAtLeast(1));
    
    // Or check for course-related text
    expect(find.textContaining('Course'), findsAtLeast(1));
  });
}