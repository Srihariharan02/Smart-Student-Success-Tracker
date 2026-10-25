import 'package:flutter/material.dart';
import '../models/assignment_model.dart';
import '../models/note_model.dart';
import '../models/notification_model.dart';
import '../models/performance_model.dart';
import '../models/student_dashboard_model.dart';
import '../models/study_task_model.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _service = StudentService();

  // Dashboard state
  bool _isLoadingDashboard = false;
  StudentDashboardModel? _dashboard;
  String? _dashboardError;

  bool get isLoadingDashboard => _isLoadingDashboard;
  StudentDashboardModel? get dashboard => _dashboard;
  String? get dashboardError => _dashboardError;

  // Performance state
  bool _isLoadingPerformance = false;
  List<SubjectPerformanceModel> _performanceSubjects = [];
  String? _performanceError;

  bool get isLoadingPerformance => _isLoadingPerformance;
  List<SubjectPerformanceModel> get performanceSubjects => _performanceSubjects;
  String? get performanceError => _performanceError;

  // Planner state
  bool _isLoadingPlanner = false;
  List<StudyTaskModel> _tasks = [];
  List<PriorityStudyRecommendation> _priorities = [];
  num _completionPercentage = 0;
  String? _plannerError;

  bool get isLoadingPlanner => _isLoadingPlanner;
  List<StudyTaskModel> get tasks => _tasks;
  List<PriorityStudyRecommendation> get priorities => _priorities;
  num get completionPercentage => _completionPercentage;
  String? get plannerError => _plannerError;

  // Assignments state
  bool _isLoadingAssignments = false;
  List<AssignmentModel> _assignments = [];
  String? _assignmentsError;

  bool get isLoadingAssignments => _isLoadingAssignments;
  List<AssignmentModel> get assignments => _assignments;
  String? get assignmentsError => _assignmentsError;

  // Notes state
  bool _isLoadingNotes = false;
  List<NoteModel> _notes = [];
  String? _notesError;

  bool get isLoadingNotes => _isLoadingNotes;
  List<NoteModel> get notes => _notes;
  String? get notesError => _notesError;

  // Notifications state
  List<NotificationModel> _notifications = [];
  int _unreadNotifsCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadNotifsCount => _unreadNotifsCount;

  // Prediction state
  Map<String, dynamic>? _prediction;
  bool _isLoadingPrediction = false;

  Map<String, dynamic>? get prediction => _prediction;
  bool get isLoadingPrediction => _isLoadingPrediction;

  // --- ACTIONS ---

  Future<void> fetchDashboard() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      _dashboard = await _service.getDashboard();
      _tasks = _dashboard!.tasks;
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> fetchPerformance() async {
    _isLoadingPerformance = true;
    _performanceError = null;
    notifyListeners();

    try {
      _performanceSubjects = await _service.getPerformance();
    } catch (e) {
      _performanceError = e.toString();
    } finally {
      _isLoadingPerformance = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlanner() async {
    _isLoadingPlanner = true;
    _plannerError = null;
    notifyListeners();

    try {
      final res = await _service.getPlanner();
      _tasks = res.tasks;
      _priorities = res.priorities;
      _completionPercentage = res.completionPercentage;
    } catch (e) {
      _plannerError = e.toString();
    } finally {
      _isLoadingPlanner = false;
      notifyListeners();
    }
  }

  Future<bool> addTask({
    required String text,
    required String subject,
    required String day,
    required int minutes,
    required String priority,
  }) async {
    try {
      final newTask = await _service.addTask(
        text: text,
        subject: subject,
        day: day,
        minutes: minutes,
        priority: priority,
      );
      _tasks.insert(0, newTask);
      _recalcCompletion();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleTask(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final current = _tasks[idx];
      _tasks[idx] = current.copyWith(isDone: !current.isDone);
      _recalcCompletion();
      notifyListeners();

      try {
        await _service.toggleTaskComplete(taskId);
      } catch (_) {
        // Revert on failure
        _tasks[idx] = current;
        _recalcCompletion();
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final removed = _tasks.removeAt(idx);
      _recalcCompletion();
      notifyListeners();

      try {
        await _service.deleteTask(taskId);
      } catch (_) {
        _tasks.insert(idx, removed);
        _recalcCompletion();
        notifyListeners();
      }
    }
  }

  void _recalcCompletion() {
    if (_tasks.isEmpty) {
      _completionPercentage = 0;
      return;
    }
    final done = _tasks.where((t) => t.isDone).length;
    _completionPercentage = ((done / _tasks.length) * 100).round();
  }

  Future<void> fetchAssignments() async {
    _isLoadingAssignments = true;
    _assignmentsError = null;
    notifyListeners();

    try {
      _assignments = await _service.getAssignments();
    } catch (e) {
      _assignmentsError = e.toString();
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  Future<bool> submitAssignment(int assignmentId, String text) async {
    try {
      await _service.submitAssignment(assignmentId, text);
      await fetchAssignments();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchNotes({String? subject}) async {
    _isLoadingNotes = true;
    _notesError = null;
    notifyListeners();

    try {
      _notes = await _service.getNotes(subject: subject);
    } catch (e) {
      _notesError = e.toString();
    } finally {
      _isLoadingNotes = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrediction() async {
    _isLoadingPrediction = true;
    notifyListeners();
    try {
      _prediction = await _service.getPrediction();
    } catch (_) {}
    _isLoadingPrediction = false;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await _service.getNotifications();
      _notifications = res.notifications;
      _unreadNotifsCount = res.unreadCount;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markNotifRead(String id) async {
    try {
      await _service.markNotificationRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        if (_unreadNotifsCount > 0) _unreadNotifsCount--;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllNotifsRead() async {
    try {
      await _service.markAllNotificationsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadNotifsCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
