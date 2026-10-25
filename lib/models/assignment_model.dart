class AssignmentModel {
  final int id;
  final String title;
  final String subject;
  final String dueDate;
  final String faculty;
  final String status; // 'Active', 'Due Soon', 'Completed'
  final String? description;
  final num? totalMarks;
  final num? obtainedScore;
  final String? submittedAt;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.faculty,
    required this.status,
    this.description,
    this.totalMarks,
    this.obtainedScore,
    this.submittedAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      return num.tryParse(val.toString());
    }

    return AssignmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? json['name'] ?? 'Assignment',
      subject: json['subject'] ?? 'General',
      dueDate: json['due_date'] ?? json['dueDate'] ?? 'Soon',
      faculty: json['faculty'] ?? json['teacher'] ?? 'Faculty',
      status: json['status'] ?? 'Active',
      description: json['description'],
      totalMarks: parseNum(json['total_marks']),
      obtainedScore: parseNum(json['obtained_score'] ?? json['score']),
      submittedAt: json['submitted_at'],
    );
  }

  bool get isCompleted => status.toLowerCase() == 'completed' || submittedAt != null;
}
