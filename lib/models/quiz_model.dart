class QuizGamificationModel {
  final int xp;
  final int streak;
  final int level;
  final int nextLevelXp;
  final List<String> badges;

  QuizGamificationModel({
    required this.xp,
    required this.streak,
    required this.level,
    required this.nextLevelXp,
    required this.badges,
  });

  factory QuizGamificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return QuizGamificationModel(xp: 120, streak: 3, level: 2, nextLevelXp: 200, badges: ['Fast Learner', 'Quiz Pro']);
    }
    final rawBadges = json['badges'] is List ? (json['badges'] as List).map((e) => e.toString()).toList() : <String>[];
    return QuizGamificationModel(
      xp: json['xp'] is int ? json['xp'] : int.tryParse(json['xp']?.toString() ?? '') ?? 0,
      streak: json['streak'] is int ? json['streak'] : int.tryParse(json['streak']?.toString() ?? '') ?? 0,
      level: json['level'] is int ? json['level'] : int.tryParse(json['level']?.toString() ?? '') ?? 1,
      nextLevelXp: json['next_level_xp'] is int ? json['next_level_xp'] : int.tryParse(json['next_level_xp']?.toString() ?? '') ?? 200,
      badges: rawBadges.isNotEmpty ? rawBadges : ['Quiz Starter'],
    );
  }
}

class QuizQuestionModel {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] is List ? (json['options'] as List).map((e) => e.toString()).toList() : <String>[];
    return QuizQuestionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      question: json['question'] ?? json['text'] ?? 'Question',
      options: opts,
      correctIndex: json['correct_index'] is int ? json['correct_index'] : int.tryParse(json['correct_index']?.toString() ?? '') ?? 0,
      explanation: json['explanation'],
    );
  }
}

class QuizDeckModel {
  final int id;
  final String title;
  final String subject;
  final int questionsCount;
  final num? lastScore;
  final num? bestScore;
  final int durationMinutes;
  final List<QuizQuestionModel> questions;

  QuizDeckModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.questionsCount,
    this.lastScore,
    this.bestScore,
    required this.durationMinutes,
    this.questions = const [],
  });

  factory QuizDeckModel.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      return num.tryParse(val.toString());
    }

    final questionsList = (json['questions'] as List? ?? [])
        .map((e) => QuizQuestionModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();

    final count = json['questions_count'] is int
        ? json['questions_count']
        : int.tryParse(json['questions_count']?.toString() ?? '') ?? (questionsList.isNotEmpty ? questionsList.length : 5);

    return QuizDeckModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? 'Quiz',
      subject: json['subject'] ?? 'General',
      questionsCount: count,
      lastScore: parseNum(json['last_score']),
      bestScore: parseNum(json['best_score']),
      durationMinutes: json['duration_mins'] is int ? json['duration_mins'] : int.tryParse(json['duration_mins']?.toString() ?? '') ?? 10,
      questions: questionsList,
    );
  }
}

class QuizArenaDataModel {
  final QuizGamificationModel gamification;
  final List<QuizDeckModel> quizzes;

  QuizArenaDataModel({
    required this.gamification,
    required this.quizzes,
  });

  factory QuizArenaDataModel.fromJson(Map<String, dynamic> json) {
    final gamificationData = QuizGamificationModel.fromJson(json['gamification']);
    final quizzesList = (json['quizzes'] as List? ?? [])
        .map((e) => QuizDeckModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();

    return QuizArenaDataModel(
      gamification: gamificationData,
      quizzes: quizzesList,
    );
  }
}
