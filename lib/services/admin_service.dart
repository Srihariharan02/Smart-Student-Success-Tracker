import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/admin_models.dart';
import '../models/teacher_models.dart';

class AdminService {
  final ApiClient _client = ApiClient();

  Future<AdminDashboardModel> getDashboard() async {
    final response = await _client.get(ApiConstants.adminDashboard);
    return AdminDashboardModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<TeacherStudentModel>> getStudents() async {
    final response = await _client.get(ApiConstants.adminStudents);
    final list = response is List ? response : (response is Map && response['students'] is List ? response['students'] as List : []);
    return list.map((e) => TeacherStudentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addStudent({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String department,
    required String year,
    required int semester,
  }) async {
    await _client.post(
      ApiConstants.adminStudents,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'student_id': studentId,
        'department': department,
        'year': year,
        'semester': semester,
        'role': 'student',
      },
    );
  }

  Future<void> deleteStudent(int id) async {
    await _client.delete('${ApiConstants.adminStudents}/$id');
  }

  Future<List<AdminTeacherModel>> getTeachers() async {
    final response = await _client.get(ApiConstants.adminTeachers);
    final list = response is List ? response : (response is Map && response['teachers'] is List ? response['teachers'] as List : []);
    return list.map((e) => AdminTeacherModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addTeacher({
    required String name,
    required String email,
    required String password,
    required String department,
    required String designation,
    required String teacherId,
  }) async {
    await _client.post(
      ApiConstants.adminTeachers,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'department': department,
        'designation': designation,
        'teacher_id': teacherId,
        'role': 'teacher',
      },
    );
  }

  Future<List<AdminSubjectModel>> getSubjects() async {
    final response = await _client.get(ApiConstants.adminSubjects);
    final list = response is List ? response : (response is Map && response['subjects'] is List ? response['subjects'] as List : []);
    return list.map((e) => AdminSubjectModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addSubject({
    required String name,
    required String code,
    required String department,
    required int semester,
    required int credits,
    int? teacherId,
  }) async {
    await _client.post(
      ApiConstants.adminSubjects,
      body: {
        'name': name,
        'code': code,
        'department': department,
        'semester': semester,
        'credits': credits,
        'teacher_id': teacherId,
      },
    );
  }
}
