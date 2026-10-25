class NoteModel {
  final int id;
  final String topic;
  final String subject;
  final String faculty;
  final String description;
  final String type; // 'PDF', 'Doc', 'Slide'
  final String date;

  NoteModel({
    required this.id,
    required this.topic,
    required this.subject,
    required this.faculty,
    required this.description,
    required this.type,
    required this.date,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      topic: json['topic'] ?? json['title'] ?? 'Note Topic',
      subject: json['subject'] ?? 'General',
      faculty: json['faculty'] ?? json['uploaded_by'] ?? 'Faculty',
      description: json['description'] ?? '',
      type: json['type'] ?? 'PDF',
      date: json['date'] ?? json['created_at'] ?? 'Recent',
    );
  }
}
