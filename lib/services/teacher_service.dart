import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/teacher_models.dart';

class TeacherService {
  final ApiClient _client = ApiClient();

  Future<TeacherDashboardModel> getDashboard() async {
    final response = await _client.get(ApiConstants.teacherDashboard);
    return TeacherDashboardModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<TeacherStudentModel>> getStudents({String? subject, String? risk}) async {
    final params = <String, dynamic>{};
    if (subject != null && subject != 'All') params['subject'] = subject;
    if (risk != null && risk != 'All') params['risk'] = risk;

    final response = await _client.get(ApiConstants.teacherStudents, queryParams: params.isNotEmpty ? params : null);
    final list = response is List ? response : (response is Map && response['students'] is List ? response['students'] as List : []);
    return list.map((e) => TeacherStudentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<InterventionAlertModel>> getAlerts() async {
    final response = await _client.get(ApiConstants.teacherAlerts);
    final list = response is List ? response : (response is Map && response['alerts'] is List ? response['alerts'] as List : []);
    return list.map((e) => InterventionAlertModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> resolveAlert(String alertId) async {
    await _client.put('${ApiConstants.teacherAlerts}/$alertId/resolve');
  }

  Future<void> submitMarks({
    required String studentId,
    required String subject,
    required num internal,
    required num external,
    required num assignment,
    required num quiz,
  }) async {
    await _client.post(
      ApiConstants.teacherMarks,
      body: {
        'student_id': studentId,
        'subject_id': subject,
        'subject': subject,
        'internal': internal,
        'external': external,
        'assignment': assignment,
        'quiz': quiz,
      },
    );
  }

  Future<void> submitAttendance({
    required String studentId,
    required String subject,
    required int attended,
    required int total,
  }) async {
    await _client.post(
      ApiConstants.teacherAttendance,
      body: {
        'student_id': studentId,
        'subject_id': subject,
        'subject': subject,
        'attended': attended,
        'total': total,
      },
    );
  }

  Future<void> createAssignment({
    required String title,
    required String subject,
    required String dueDate,
    required String description,
    required num totalMarks,
  }) async {
    await _client.post(
      ApiConstants.teacherAssignments,
      body: {
        'title': title,
        'subject': subject,
        'due_date': dueDate,
        'description': description,
        'total_marks': totalMarks,
      },
    );
  }

  Future<void> createNote({
    required String topic,
    required String subject,
    required String description,
    required String type,
  }) async {
    await _client.post(
      ApiConstants.teacherNotes,
      body: {
        'topic': topic,
        'subject': subject,
        'description': description,
        'type': type,
      },
    );
  }
}
