import 'performance_model.dart';
import 'study_task_model.dart';

class AcademicInsightsModel {
  final List<String> strengths;
  final List<String> weakAreas;
  final List<String> recommendations;

  AcademicInsightsModel({
    required this.strengths,
    required this.weakAreas,
    required this.recommendations,
  });

  factory AcademicInsightsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AcademicInsightsModel(strengths: [], weakAreas: [], recommendations: []);
    }
    List<String> parseList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return [];
    }

    return AcademicInsightsModel(
      strengths: parseList(json['strengths']),
      weakAreas: parseList(json['weak_areas'] ?? json['weakAreas']),
      recommendations: parseList(json['recommendations']),
    );
  }
}

class TrendDataModel {
  final List<String> labels;
  final List<double> values;

  TrendDataModel({
    required this.labels,
    required this.values,
  });

  factory TrendDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TrendDataModel(labels: const [], values: const []);
    }
    final rawLabels = json['labels'] is List ? (json['labels'] as List).map((e) => e.toString()).toList() : <String>[];
    final rawValues = json['values'] is List
        ? (json['values'] as List).map((e) => (e is num) ? e.toDouble() : double.tryParse(e.toString()) ?? 0.0).toList()
        : <double>[];

    return TrendDataModel(
      labels: rawLabels,
      values: rawValues,
    );
  }
}

class StudentDashboardModel {
  final String studentId;
  final String name;
  final String year;
  final int semester;
  final num overallPercentage;
  final String status;
  final num attendancePercentage;
  final num averageMarks;
  final num assignmentCompletion;
  final num quizPerformance;
  final String academicRisk;
  final TrendDataModel trendData;
  final List<SubjectPerformanceModel> subjects;
  final AcademicInsightsModel insights;
  final List<StudyTaskModel> tasks;

  StudentDashboardModel({
    required this.studentId,
    required this.name,
    required this.year,
    required this.semester,
    required this.overallPercentage,
    required this.status,
    required this.attendancePercentage,
    required this.averageMarks,
    required this.assignmentCompletion,
    required this.quizPerformance,
    required this.academicRisk,
    required this.trendData,
    required this.subjects,
    required this.insights,
    required this.tasks,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val, [num defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? defaultVal;
    }

    final subjectsList = (json['subjects'] as List? ?? [])
        .map((e) => SubjectPerformanceModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();

    final tasksList = (json['tasks'] as List? ?? [])
        .map((e) => StudyTaskModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();

    TrendDataModel trend;
    if (json['trend_data'] is Map<String, dynamic>) {
      trend = TrendDataModel.fromJson(json['trend_data']);
    } else if (json['trendLabels'] is List && json['trend'] is List) {
      trend = TrendDataModel(
        labels: (json['trendLabels'] as List).map((e) => e.toString()).toList(),
        values: (json['trend'] as List).map((e) => (e is num) ? e.toDouble() : double.tryParse(e.toString()) ?? 0.0).toList(),
      );
    } else {
      trend = TrendDataModel.fromJson(null);
    }

    return StudentDashboardModel(
      studentId: json['student_id'] ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'Student',
      year: json['year'] ?? 'Final Year',
      semester: json['semester'] is int ? json['semester'] : int.tryParse(json['semester']?.toString() ?? '') ?? 8,
      overallPercentage: parseNum(json['overall'] ?? json['overall_percentage']),
      status: json['status'] ?? 'Good',
      attendancePercentage: parseNum(json['attendance'] ?? json['attendance_percentage']),
      averageMarks: parseNum(json['average_marks']),
      assignmentCompletion: parseNum(json['assignment_completion']),
      quizPerformance: parseNum(json['quiz_performance']),
      academicRisk: json['academic_risk'] ?? 'Low Risk',
      trendData: trend,
      subjects: subjectsList,
      insights: AcademicInsightsModel.fromJson(json['insights']),
      tasks: tasksList,
    );
  }
}
