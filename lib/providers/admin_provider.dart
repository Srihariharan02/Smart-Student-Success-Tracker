import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../models/teacher_models.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _service = AdminService();

  bool _isLoadingDashboard = false;
  AdminDashboardModel? _dashboard;
  String? _dashboardError;

  bool get isLoadingDashboard => _isLoadingDashboard;
  AdminDashboardModel? get dashboard => _dashboard;
  String? get dashboardError => _dashboardError;

  bool _isLoadingStudents = false;
  List<TeacherStudentModel> _students = [];

  bool get isLoadingStudents => _isLoadingStudents;
  List<TeacherStudentModel> get students => _students;

  bool _isLoadingTeachers = false;
  List<AdminTeacherModel> _teachers = [];

  bool get isLoadingTeachers => _isLoadingTeachers;
  List<AdminTeacherModel> get teachers => _teachers;

  bool _isLoadingSubjects = false;
  List<AdminSubjectModel> _subjects = [];

  bool get isLoadingSubjects => _isLoadingSubjects;
  List<AdminSubjectModel> get subjects => _subjects;

  Future<void> fetchDashboard() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      _dashboard = await _service.getDashboard();
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudents() async {
    _isLoadingStudents = true;
    notifyListeners();
    try {
      _students = await _service.getStudents();
    } catch (_) {} finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String department,
    required String year,
    required int semester,
  }) async {
    try {
      await _service.addStudent(
        name: name,
        email: email,
        password: password,
        studentId: studentId,
        department: department,
        year: year,
        semester: semester,
      );
      await fetchStudents();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteStudent(TeacherStudentModel student) async {
    final id = student.id;
    if (id == null) return false;
    try {
      await _service.deleteStudent(id);
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchTeachers() async {
    _isLoadingTeachers = true;
    notifyListeners();
    try {
      _teachers = await _service.getTeachers();
    } catch (_) {} finally {
      _isLoadingTeachers = false;
      notifyListeners();
    }
  }

  Future<bool> addTeacher({
    required String name,
    required String email,
    required String password,
    required String department,
    required String designation,
    required String teacherId,
  }) async {
    try {
      await _service.addTeacher(
        name: name,
        email: email,
        password: password,
        department: department,
        designation: designation,
        teacherId: teacherId,
      );
      await fetchTeachers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchSubjects() async {
    _isLoadingSubjects = true;
    notifyListeners();
    try {
      _subjects = await _service.getSubjects();
    } catch (_) {} finally {
      _isLoadingSubjects = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject({
    required String name,
    required String code,
    required String department,
    required int semester,
    required int credits,
    int? teacherId,
  }) async {
    try {
      await _service.addSubject(
        name: name,
        code: code,
        department: department,
        semester: semester,
        credits: credits,
        teacherId: teacherId,
      );
      await fetchSubjects();
      return true;
    } catch (_) {
      return false;
    }
  }
}
