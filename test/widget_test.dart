import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:s3t_mobile/app/app.dart';
import 'package:s3t_mobile/core/storage/local_storage.dart';
import 'package:s3t_mobile/providers/auth_provider.dart';
import 'package:s3t_mobile/providers/theme_provider.dart';
import 'package:s3t_mobile/providers/student_provider.dart';
import 'package:s3t_mobile/providers/teacher_provider.dart';
import 'package:s3t_mobile/providers/admin_provider.dart';
import 'package:s3t_mobile/providers/quiz_provider.dart';
import 'package:s3t_mobile/widgets/kpi_card.dart';
import 'package:s3t_mobile/widgets/stat_progress_bar.dart';
import 'package:s3t_mobile/widgets/custom_button.dart';

void main() {
  testWidgets('SSST App smoke test and initial render', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => TeacherProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProvider(create: (_) => QuizProvider()),
        ],
        child: const S3TApp(),
      ),
    );

    expect(find.text('SSST'), findsOneWidget);
    expect(find.text('Smart Student Success Tracker'), findsOneWidget);

    // Advance timers so pending async splash timer resolves cleanly
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });

  testWidgets('KpiCard renders metrics and labels properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            label: 'Overall Score',
            value: '88%',
            subtitle: 'Status: Excellent',
            icon: Icons.trending_up,
            tone: 'brand',
          ),
        ),
      ),
    );

    expect(find.text('Overall Score'), findsOneWidget);
    expect(find.text('88%'), findsOneWidget);
    expect(find.text('Status: Excellent'), findsOneWidget);
  });

  testWidgets('StatProgressBar and CustomButton render correctly', (WidgetTester tester) async {
    bool clicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const StatProgressBar(percentage: 75),
              CustomButton(
                text: 'Click Me',
                onPressed: () => clicked = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);
    await tester.tap(find.text('Click Me'));
    expect(clicked, true);
  });
}
