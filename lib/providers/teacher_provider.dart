import 'package:flutter/material.dart';
import '../models/teacher_models.dart';
import '../services/teacher_service.dart';

class TeacherProvider with ChangeNotifier {
  final TeacherService _service = TeacherService();

  bool _isLoadingDashboard = false;
  TeacherDashboardModel? _dashboard;
  String? _dashboardError;

  bool get isLoadingDashboard => _isLoadingDashboard;
  TeacherDashboardModel? get dashboard => _dashboard;
  String? get dashboardError => _dashboardError;

  bool _isLoadingStudents = false;
  List<TeacherStudentModel> _students = [];
  String? _studentsError;

  bool get isLoadingStudents => _isLoadingStudents;
  List<TeacherStudentModel> get students => _students;
  String? get studentsError => _studentsError;

  bool _isLoadingAlerts = false;
  List<InterventionAlertModel> _alerts = [];

  bool get isLoadingAlerts => _isLoadingAlerts;
  List<InterventionAlertModel> get alerts => _alerts;

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

  Future<void> fetchStudents({String? subject, String? risk}) async {
    _isLoadingStudents = true;
    _studentsError = null;
    notifyListeners();

    try {
      _students = await _service.getStudents(subject: subject, risk: risk);
    } catch (e) {
      _studentsError = e.toString();
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  Future<void> fetchAlerts() async {
    _isLoadingAlerts = true;
    notifyListeners();

    try {
      _alerts = await _service.getAlerts();
    } catch (_) {} finally {
      _isLoadingAlerts = false;
      notifyListeners();
    }
  }

  Future<bool> resolveAlert(String alertId) async {
    try {
      await _service.resolveAlert(alertId);
      final idx = _alerts.indexWhere((a) => a.id == alertId);
      if (idx != -1) {
        _alerts[idx] = _alerts[idx].copyWith(isResolved: true);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitMarks({
    required String studentId,
    required String subject,
    required num internal,
    required num external,
    required num assignment,
    required num quiz,
  }) async {
    try {
      await _service.submitMarks(
        studentId: studentId,
        subject: subject,
        internal: internal,
        external: external,
        assignment: assignment,
        quiz: quiz,
      );
      await fetchStudents();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitAttendance({
    required String studentId,
    required String subject,
    required int attended,
    required int total,
  }) async {
    try {
      await _service.submitAttendance(
        studentId: studentId,
        subject: subject,
        attended: attended,
        total: total,
      );
      await fetchStudents();
      return true;
    } catch (_) {
      return false;
    }
  }
}
