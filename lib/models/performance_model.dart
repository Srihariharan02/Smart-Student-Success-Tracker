class SubjectPerformanceModel {
  final int? id;
  final String name;
  final String? code;
  final String faculty;
  final num internalMarks;
  final num externalMarks;
  final num assignmentMarks;
  final num quizMarks;
  final num attendance;
  final num overall;
  final String grade;
  final String status;

  SubjectPerformanceModel({
    this.id,
    required this.name,
    this.code,
    required this.faculty,
    required this.internalMarks,
    required this.externalMarks,
    required this.assignmentMarks,
    required this.quizMarks,
    required this.attendance,
    required this.overall,
    required this.grade,
    required this.status,
  });

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val, [num defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? defaultVal;
    }

    return SubjectPerformanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] ?? json['subject'] ?? 'Subject',
      code: json['code'] ?? json['subject_code'],
      faculty: json['faculty'] ?? 'Faculty',
      internalMarks: parseNum(json['internal'] ?? json['internal_marks']),
      externalMarks: parseNum(json['external'] ?? json['external_marks']),
      assignmentMarks: parseNum(json['assignment'] ?? json['assignment_marks']),
      quizMarks: parseNum(json['quiz'] ?? json['quiz_marks']),
      attendance: parseNum(json['attendance'] ?? json['attendance_percentage']),
      overall: parseNum(json['overall'] ?? json['overall_percentage']),
      grade: json['grade'] ?? '—',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'faculty': faculty,
      'internal': internalMarks,
      'external': externalMarks,
      'assignment': assignmentMarks,
      'quiz': quizMarks,
      'attendance': attendance,
      'overall': overall,
      'grade': grade,
      'status': status,
    };
  }
}
