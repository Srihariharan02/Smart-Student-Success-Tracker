import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/constants/api_constants.dart';
import 'core/storage/local_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/quiz_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await LocalStorage.init();
  final savedBase = LocalStorage.getApiBaseUrl();
  if (savedBase != null && savedBase.isNotEmpty) {
    ApiConstants.customBaseUrl = savedBase;
  }

  runApp(
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
}
