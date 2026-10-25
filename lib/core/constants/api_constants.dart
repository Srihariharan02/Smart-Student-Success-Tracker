import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConstants {
  ApiConstants._();

  /// Compile-time override:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000/api
  static const String definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const String defaultLanIp = '192.168.0.106';

  /// Default Base URL:
  /// - Android emulator: http://10.0.2.2:5000/api
  /// - iOS simulator / Web: http://127.0.0.1:5000/api
  /// - Physical phone: http://192.168.0.106:5000/api
  static String get baseUrl {
    if (definedBaseUrl.isNotEmpty) return sanitizeBaseUrl(definedBaseUrl);
    if (kIsWeb) return 'http://127.0.0.1:5000/api';
    try {
      if (Platform.isAndroid) {
        return 'http://$defaultLanIp:5000/api';
      }
      if (Platform.isIOS) {
        return 'http://$defaultLanIp:5000/api';
      }
    } catch (_) {}
    return 'http://$defaultLanIp:5000/api';
  }

  /// Cleans, normalizes, and validates any user-entered server URL
  static String sanitizeBaseUrl(String raw) {
    var url = raw.trim();
    if (url.isEmpty) return baseUrl;

    // Add protocol if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // Strip trailing slashes
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // If port 5000 was omitted from host, add it
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasPort == false && !uri.host.contains(':')) {
      final host = uri.host;
      final scheme = uri.scheme;
      final path = uri.path;
      url = '$scheme://$host:5000$path';
    }

    // Strip trailing slashes again
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // Ensure it ends with /api
    if (!url.endsWith('/api')) {
      url = '$url/api';
    }

    return url;
  }

  /// Runtime override persisted in Settings (physical device testing).
  static String? customBaseUrl;
  static String get activeBaseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return sanitizeBaseUrl(customBaseUrl!);
    }
    return baseUrl;
  }

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Student Endpoints
  static const String studentDashboard = '/student/dashboard';
  static const String studentPerformance = '/student/performance';
  static const String studentTrend = '/student/performance/trend';
  static const String studentPrediction = '/student/prediction';
  static const String studentInsights = '/student/insights';
  static const String studentSuggestions = '/student/suggestions';
  static const String studentParentReport = '/student/parent-report';
  static const String studentAiChat = '/student/ai-chat';
  static const String studentPlanner = '/student/planner';

  // Teacher Endpoints
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherStudents = '/teacher/students';
  static const String teacherAlerts = '/teacher/alerts';
  static const String teacherMarks = '/teacher/marks';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherNotes = '/teacher/notes';
  static const String teacherQuizzes = '/teacher/quizzes';
  static const String teacherAssignments = '/teacher/assignments';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminStudents = '/admin/students';
  static const String adminTeachers = '/admin/teachers';
  static const String adminSubjects = '/admin/subjects';
  static const String adminAlerts = '/admin/alerts';

  // Shared Endpoints
  static const String assignments = '/assignments';
  static const String notes = '/notes';
  static const String quizzes = '/quizzes';
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String settings = '/settings';
  static const String search = '/search';
}
