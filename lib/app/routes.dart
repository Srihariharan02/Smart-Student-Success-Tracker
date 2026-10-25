class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  
  // Student
  static const String studentMain = '/student';
  static const String studentDashboard = '/student/dashboard';
  static const String studentPerformance = '/student/performance';
  static const String studentPlanner = '/student/planner';
  static const String studentInsights = '/student/insights';
  static const String studentPrediction = '/student/prediction';
  static const String studentAssignments = '/student/assignments';
  static const String studentNotes = '/student/notes';
  static const String studentQuiz = '/student/quiz';
  static const String studentQuizPlay = '/student/quiz/play';
  static const String studentParentReport = '/student/parent-report';
  static const String studentAiChat = '/student/ai-chat';

  // Teacher
  static const String teacherMain = '/teacher';
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherStudents = '/teacher/students';
  static const String teacherAlerts = '/teacher/alerts';
  static const String teacherAssignments = '/teacher/assignments';

  // Admin
  static const String adminMain = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStudents = '/admin/students';
  static const String adminTeachers = '/admin/teachers';
  static const String adminSubjects = '/admin/subjects';

  // Shared
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String search = '/search';
}
