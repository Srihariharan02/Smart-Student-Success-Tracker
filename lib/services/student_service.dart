import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/assignment_model.dart';
import '../models/note_model.dart';
import '../models/notification_model.dart';
import '../models/performance_model.dart';
import '../models/student_dashboard_model.dart';
import '../models/study_task_model.dart';

class StudentService {
  final ApiClient _client = ApiClient();

  Future<StudentDashboardModel> getDashboard() async {
    final response = await _client.get(ApiConstants.studentDashboard);
    return StudentDashboardModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<SubjectPerformanceModel>> getPerformance() async {
    final response = await _client.get(ApiConstants.studentPerformance);
    final data = response as Map<String, dynamic>;
    final subjects = data['subjects'] as List? ?? [];
    return subjects.map((e) => SubjectPerformanceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getPrediction() async {
    final response = await _client.get(ApiConstants.studentPrediction);
    return response as Map<String, dynamic>;
  }

  Future<AcademicInsightsModel> getInsights() async {
    final response = await _client.get(ApiConstants.studentInsights);
    return AcademicInsightsModel.fromJson(response as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getParentReport() async {
    final response = await _client.get(ApiConstants.studentParentReport);
    return response as Map<String, dynamic>;
  }

  // Planner
  Future<({List<StudyTaskModel> tasks, List<PriorityStudyRecommendation> priorities, num completionPercentage})> getPlanner() async {
    final response = await _client.get(ApiConstants.studentPlanner);
    final data = response as Map<String, dynamic>;
    
    final tasks = (data['tasks'] as List? ?? [])
        .map((e) => StudyTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final priorities = (data['priorities'] as List? ?? [])
        .map((e) => PriorityStudyRecommendation.fromJson(e as Map<String, dynamic>))
        .toList();

    final num completion = data['completion_percentage'] is num
        ? (data['completion_percentage'] as num)
        : (num.tryParse(data['completion_percentage']?.toString() ?? '') ?? 0);

    return (tasks: tasks, priorities: priorities, completionPercentage: completion);
  }

  Future<StudyTaskModel> addTask({
    required String text,
    required String subject,
    required String day,
    required int minutes,
    required String priority,
  }) async {
    final response = await _client.post(
      ApiConstants.studentPlanner,
      body: {
        'text': text,
        'subject': subject,
        'day': day,
        'minutes': minutes,
        'priority': priority,
      },
    );
    final data = response as Map<String, dynamic>;
    final taskData = data['task'] is Map<String, dynamic> ? data['task'] as Map<String, dynamic> : data;
    return StudyTaskModel.fromJson(taskData);
  }

  Future<void> toggleTaskComplete(String taskId) async {
    await _client.put('${ApiConstants.studentPlanner}/$taskId/complete');
  }

  Future<void> deleteTask(String taskId) async {
    await _client.delete('${ApiConstants.studentPlanner}/$taskId');
  }

  // Assignments
  Future<List<AssignmentModel>> getAssignments() async {
    final response = await _client.get(ApiConstants.assignments);
    final list = response is List ? response : (response is Map && response['assignments'] is List ? response['assignments'] as List : []);
    return list.map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> submitAssignment(int assignmentId, String submissionText) async {
    await _client.post(
      '${ApiConstants.studentDashboard.replaceAll('/dashboard', '')}/assignments/$assignmentId/submit',
      body: {'submission_text': submissionText},
    );
  }

  // Notes
  Future<List<NoteModel>> getNotes({String? subject}) async {
    final params = (subject != null && subject != 'All') ? {'subject': subject} : null;
    final response = await _client.get(ApiConstants.notes, queryParams: params);
    final list = response is List ? response : (response is Map && response['notes'] is List ? response['notes'] as List : []);
    return list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Notifications
  Future<({List<NotificationModel> notifications, int unreadCount})> getNotifications() async {
    final response = await _client.get(ApiConstants.notifications);
    final data = response as Map<String, dynamic>;
    final list = (data['notifications'] as List? ?? [])
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final int unread = data['unread_count'] is int
        ? (data['unread_count'] as int)
        : (int.tryParse(data['unread_count']?.toString() ?? '') ?? list.where((n) => !n.isRead).length);

    return (notifications: list, unreadCount: unread);
  }

  Future<void> markNotificationRead(String id) async {
    await _client.put('${ApiConstants.notifications}/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _client.put(ApiConstants.notificationsReadAll);
  }

  // Global Search
  Future<List<Map<String, dynamic>>> search(String query) async {
    final response = await _client.get(ApiConstants.search, queryParams: {'q': query});
    final data = response as Map<String, dynamic>;
    final results = data['results'] as List? ?? [];
    return results.map((e) => e as Map<String, dynamic>).toList();
  }
}
