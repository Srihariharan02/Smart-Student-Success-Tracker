class StudyTaskModel {
  final String id;
  final String text;
  final String subject;
  final String day;
  final int minutes;
  final String priority;
  final bool isDone;

  StudyTaskModel({
    required this.id,
    required this.text,
    required this.subject,
    required this.day,
    required this.minutes,
    required this.priority,
    required this.isDone,
  });

  factory StudyTaskModel.fromJson(Map<String, dynamic> json) {
    return StudyTaskModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? json['title'] ?? 'Study Task',
      subject: json['subject'] ?? 'General',
      day: json['day'] ?? 'Monday',
      minutes: json['minutes'] is int ? json['minutes'] : int.tryParse(json['minutes']?.toString() ?? '') ?? 30,
      priority: json['priority'] ?? 'Medium',
      isDone: json['done'] == true || json['is_done'] == true || json['completed'] == true,
    );
  }

  StudyTaskModel copyWith({bool? isDone, String? text, String? day, int? minutes, String? priority}) {
    return StudyTaskModel(
      id: id,
      text: text ?? this.text,
      subject: subject,
      day: day ?? this.day,
      minutes: minutes ?? this.minutes,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'subject': subject,
      'day': day,
      'minutes': minutes,
      'priority': priority,
      'done': isDone,
    };
  }
}

class PriorityStudyRecommendation {
  final String subject;
  final String level;
  final String recommendation;
  final String tone;

  PriorityStudyRecommendation({
    required this.subject,
    required this.level,
    required this.recommendation,
    required this.tone,
  });

  factory PriorityStudyRecommendation.fromJson(Map<String, dynamic> json) {
    return PriorityStudyRecommendation(
      subject: json['name'] ?? json['subject'] ?? 'Subject',
      level: json['level'] ?? 'Priority',
      recommendation: json['rec'] ?? json['recommendation'] ?? '',
      tone: json['tone'] ?? 'warn',
    );
  }
}
