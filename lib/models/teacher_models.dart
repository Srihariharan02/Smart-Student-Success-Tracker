class TeacherStudentModel {
  final int? id;
  final String studentId;
  final String name;
  final String email;
  final String? department;
  final String? year;
  final int? semester;
  final String? subject;
  final num attendance;
  final num overall;
  final num internalMarks;
  final num externalMarks;
  final num assignmentMarks;
  final num quizMarks;
  final String riskLevel;

  TeacherStudentModel({
    this.id,
    required this.studentId,
    required this.name,
    required this.email,
    this.department,
    this.year,
    this.semester,
    this.subject,
    required this.attendance,
    required this.overall,
    required this.internalMarks,
    required this.externalMarks,
    required this.assignmentMarks,
    required this.quizMarks,
    required this.riskLevel,
  });

  factory TeacherStudentModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val, [num defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? defaultVal;
    }

    return TeacherStudentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentId: json['student_id'] ?? json['id_code'] ?? 'STU',
      name: json['name'] ?? json['full_name'] ?? 'Student',
      email: json['email'] ?? '',
      department: json['department'],
      year: json['year'],
      semester: json['semester'] is int ? json['semester'] : int.tryParse(json['semester']?.toString() ?? ''),
      subject: json['subject'] ?? json['subject_name'],
      attendance: parseNum(json['attendance'] ?? json['attendance_percentage']),
      overall: parseNum(json['overall'] ?? json['overall_percentage']),
      internalMarks: parseNum(json['internal'] ?? json['internal_marks']),
      externalMarks: parseNum(json['external'] ?? json['external_marks']),
      assignmentMarks: parseNum(json['assignment'] ?? json['assignment_marks']),
      quizMarks: parseNum(json['quiz'] ?? json['quiz_marks']),
      riskLevel: json['risk_level'] ?? json['academic_risk'] ?? 'Low Risk',
    );
  }
}

class InterventionAlertModel {
  final String id;
  final String studentName;
  final String studentId;
  final String subject;
  final String severity; // 'Critical', 'Warning', 'Info'
  final String issue;
  final String timestamp;
  final bool isResolved;

  InterventionAlertModel({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.subject,
    required this.severity,
    required this.issue,
    required this.timestamp,
    required this.isResolved,
  });

  factory InterventionAlertModel.fromJson(Map<String, dynamic> json) {
    return InterventionAlertModel(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name'] ?? json['studentName'] ?? 'Student',
      studentId: json['student_id'] ?? json['studentId'] ?? '',
      subject: json['subject'] ?? 'General',
      severity: json['severity'] ?? json['level'] ?? 'Warning',
      issue: json['issue'] ?? json['message'] ?? 'Needs academic intervention',
      timestamp: json['timestamp'] ?? json['date'] ?? 'Recent',
      isResolved: json['resolved'] == true || json['is_resolved'] == true,
    );
  }

  InterventionAlertModel copyWith({bool? isResolved}) {
    return InterventionAlertModel(
      id: id,
      studentName: studentName,
      studentId: studentId,
      subject: subject,
      severity: severity,
      issue: issue,
      timestamp: timestamp,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

class TeacherDashboardModel {
  final int totalStudents;
  final num classAverage;
  final num attendanceRate;
  final int atRiskCount;
  final List<TeacherStudentModel> atRiskStudents;
  final List<InterventionAlertModel> alerts;

  TeacherDashboardModel({
    required this.totalStudents,
    required this.classAverage,
    required this.attendanceRate,
    required this.atRiskCount,
    required this.atRiskStudents,
    required this.alerts,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val, [num defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? defaultVal;
    }

    final atRiskList = (json['at_risk_students'] as List? ?? [])
        .map((e) => TeacherStudentModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();

    final alertsList = (json['alerts'] as List? ?? [])
        .map((e) => InterventionAlertModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();

    return TeacherDashboardModel(
      totalStudents: json['total_students'] is int ? json['total_students'] : int.tryParse(json['total_students']?.toString() ?? '') ?? 0,
      classAverage: parseNum(json['class_average']),
      attendanceRate: parseNum(json['attendance_rate']),
      atRiskCount: json['at_risk_count'] is int ? json['at_risk_count'] : int.tryParse(json['at_risk_count']?.toString() ?? '') ?? atRiskList.length,
      atRiskStudents: atRiskList,
      alerts: alertsList,
    );
  }
}
