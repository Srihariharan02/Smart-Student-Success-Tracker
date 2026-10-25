import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'theme.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/student/student_main_nav.dart';
import '../screens/student/performance_screen.dart';
import '../screens/student/study_planner_screen.dart';
import '../screens/student/quiz_arena_screen.dart';
import '../screens/student/assignments_screen.dart';
import '../screens/student/notes_hub_screen.dart';
import '../screens/student/prediction_screen.dart';
import '../screens/student/parent_report_screen.dart';
import '../screens/student/ai_chat_screen.dart';
import '../screens/teacher/teacher_main_nav.dart';
import '../screens/teacher/teacher_students_screen.dart';
import '../screens/teacher/teacher_alerts_screen.dart';
import '../screens/admin/admin_main_nav.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/common/settings_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class S3TApp extends StatefulWidget {
  const S3TApp({super.key});

  @override
  State<S3TApp> createState() => _S3TAppState();
}

class _S3TAppState extends State<S3TApp> {
  @override
  void initState() {
    super.initState();
    ApiClient().onUnauthorized = () async {
      await LocalStorage.clearToken();
      await LocalStorage.clearUser();
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.forceLogout();
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Smart Student Success Tracker',
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.studentMain: (context) => const StudentMainNav(),
            AppRoutes.studentPerformance: (context) => const PerformanceScreen(),
            AppRoutes.studentPlanner: (context) => const StudyPlannerScreen(),
            AppRoutes.studentQuiz: (context) => const QuizArenaScreen(),
            AppRoutes.studentAssignments: (context) => const AssignmentsScreen(),
            AppRoutes.studentNotes: (context) => const NotesHubScreen(),
            AppRoutes.studentPrediction: (context) => const PredictionScreen(),
            AppRoutes.studentParentReport: (context) => const ParentReportScreen(),
            AppRoutes.studentAiChat: (context) => const AiChatScreen(),
            AppRoutes.teacherMain: (context) => const TeacherMainNav(),
            AppRoutes.teacherStudents: (context) => const TeacherStudentsScreen(),
            AppRoutes.teacherAlerts: (context) => const TeacherAlertsScreen(),
            AppRoutes.adminMain: (context) => const AdminMainNav(),
            AppRoutes.notifications: (context) => const NotificationsScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
