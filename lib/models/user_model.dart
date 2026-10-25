class UserModel {
  final int? id;
  final String name;
  final String email;
  final String role; // 'student', 'teacher', 'admin'
  final String? studentId;
  final String? department;
  final String? designation;
  final String? year;
  final int? semester;
  final String? initials;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.department,
    this.designation,
    this.year,
    this.semester,
    this.initials,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['full_name'] ?? json['name'] ?? 'User';
    String? calcInitials = json['initials'];
    if (calcInitials == null || calcInitials.isEmpty) {
      final parts = rawName.toString().trim().split(' ');
      if (parts.length >= 2) {
        calcInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (rawName.toString().isNotEmpty) {
        calcInitials = rawName.toString().substring(0, rawName.toString().length >= 2 ? 2 : 1).toUpperCase();
      } else {
        calcInitials = 'U';
      }
    }

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: rawName,
      email: json['email'] ?? '',
      role: (json['role'] ?? 'student').toString().toLowerCase(),
      studentId: json['student_id'] ?? json['id_code'],
      department: json['department'],
      designation: json['designation'],
      year: json['year'],
      semester: json['semester'] is int ? json['semester'] : int.tryParse(json['semester']?.toString() ?? ''),
      initials: calcInitials,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': name,
      'email': email,
      'role': role,
      'student_id': studentId,
      'department': department,
      'designation': designation,
      'year': year,
      'semester': semester,
      'initials': initials,
    };
  }
}
