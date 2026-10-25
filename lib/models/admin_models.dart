class AdminSubjectModel {
  final int id;
  final String name;
  final String? code;
  final String? department;
  final int? semester;
  final int? credits;
  final String? facultyName;
  final int? teacherId;

  AdminSubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.department,
    this.semester,
    this.credits,
    this.facultyName,
    this.teacherId,
  });

  factory AdminSubjectModel.fromJson(Map<String, dynamic> json) {
    return AdminSubjectModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? json['subject_name'] ?? 'Subject',
      code: json['code'] ?? json['subject_code'],
      department: json['department'],
      semester: json['semester'] is int ? json['semester'] : int.tryParse(json['semester']?.toString() ?? ''),
      credits: json['credits'] is int ? json['credits'] : int.tryParse(json['credits']?.toString() ?? ''),
      facultyName: json['faculty_name'] ?? json['faculty'] ?? json['teacher_name'],
      teacherId: json['teacher_id'] is int ? json['teacher_id'] : int.tryParse(json['teacher_id']?.toString() ?? ''),
    );
  }
}

class AdminTeacherModel {
  final int id;
  final String name;
  final String email;
  final String? teacherId;
  final String? department;
  final String? designation;
  final List<String> subjectsAssigned;

  AdminTeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.teacherId,
    this.department,
    this.designation,
    this.subjectsAssigned = const [],
  });

  factory AdminTeacherModel.fromJson(Map<String, dynamic> json) {
    final rawSubjs = json['subjects'] is List
        ? (json['subjects'] as List).map((e) => e.toString()).toList()
        : (json['subjects_assigned'] is List ? (json['subjects_assigned'] as List).map((e) => e.toString()).toList() : <String>[]);

    return AdminTeacherModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? json['full_name'] ?? 'Faculty Member',
      email: json['email'] ?? '',
      teacherId: json['teacher_id']?.toString(),
      department: json['department'],
      designation: json['designation'] ?? 'Professor',
      subjectsAssigned: rawSubjs,
    );
  }
}

class AdminDashboardModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalSubjects;
  final int totalDepartments;
  final String systemHealth;

  AdminDashboardModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalSubjects,
    required this.totalDepartments,
    required this.systemHealth,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalStudents: json['total_students'] is int ? json['total_students'] : int.tryParse(json['total_students']?.toString() ?? '') ?? 0,
      totalTeachers: json['total_teachers'] is int ? json['total_teachers'] : int.tryParse(json['total_teachers']?.toString() ?? '') ?? 0,
      totalSubjects: json['total_subjects'] is int ? json['total_subjects'] : int.tryParse(json['total_subjects']?.toString() ?? '') ?? 0,
      totalDepartments: json['total_departments'] is int ? json['total_departments'] : int.tryParse(json['total_departments']?.toString() ?? '') ?? 0,
      systemHealth: json['system_health'] ?? 'Optimal',
    );
  }
}
