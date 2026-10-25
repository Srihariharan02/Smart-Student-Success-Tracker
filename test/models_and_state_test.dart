import 'package:flutter_test/flutter_test.dart';
import 'package:s3t_mobile/models/user_model.dart';
import 'package:s3t_mobile/models/performance_model.dart';
import 'package:s3t_mobile/models/study_task_model.dart';
import 'package:s3t_mobile/models/assignment_model.dart';
import 'package:s3t_mobile/models/quiz_model.dart';

void main() {
  group('S3T Data Models Unit Tests', () {
    test('UserModel.fromJson parses student and faculty payloads', () {
      final studentJson = {
        'id': 1,
        'name': 'Sri Hariharan',
        'email': 'student@s3t.com',
        'role': 'student',
        'student_id': 'STU2026001',
        'department': 'ECE',
        'year': 'Final Year',
        'semester': 8,
      };

      final user = UserModel.fromJson(studentJson);
      expect(user.name, 'Sri Hariharan');
      expect(user.studentId, 'STU2026001');
      expect(user.role, 'student');
      expect(user.initials, 'SH');
    });

    test('SubjectPerformanceModel.fromJson parses numeric values and calculate grade', () {
      final subjectJson = {
        'subject': 'Java Programming',
        'faculty': 'Dr. Kumar',
        'internal': 90,
        'external': 85,
        'assignment': 92,
        'quiz': 88,
        'attendance': 95,
        'overall': 88,
        'grade': 'S',
        'status': 'Excellent',
      };

      final sub = SubjectPerformanceModel.fromJson(subjectJson);
      expect(sub.name, 'Java Programming');
      expect(sub.faculty, 'Dr. Kumar');
      expect(sub.overall, 88);
      expect(sub.grade, 'S');
    });

    test('StudyTaskModel toggle and completion logic', () {
      final taskJson = {
        'id': '101',
        'text': 'Revise Queue Data Structures',
        'subject': 'Java Programming',
        'day': 'Monday',
        'minutes': 45,
        'priority': 'High',
        'done': false,
      };

      final task = StudyTaskModel.fromJson(taskJson);
      expect(task.isDone, false);
      final toggled = task.copyWith(isDone: true);
      expect(toggled.isDone, true);
    });

    test('AssignmentModel status and completed check', () {
      final assignmentJson = {
        'id': 1,
        'title': 'Fourier Transform Analysis',
        'subject': 'Communication Systems',
        'due_date': '25 Sep 2026',
        'faculty': 'Dr. Kumar',
        'status': 'Active',
      };

      final a = AssignmentModel.fromJson(assignmentJson);
      expect(a.title, 'Fourier Transform Analysis');
      expect(a.isCompleted, false);
    });

    test('QuizArenaDataModel gamification and questions parsing', () {
      final arenaJson = {
        'gamification': {
          'xp': 180,
          'streak': 5,
          'level': 3,
          'next_level_xp': 300,
          'badges': ['Streak Master', 'Quiz Expert'],
        },
        'quizzes': [
          {
            'id': 1,
            'title': 'Java OOP Quiz',
            'subject': 'Java Programming',
            'questions_count': 5,
            'duration_mins': 10,
          }
        ],
      };

      final arena = QuizArenaDataModel.fromJson(arenaJson);
      expect(arena.gamification.level, 3);
      expect(arena.gamification.streak, 5);
      expect(arena.quizzes.length, 1);
      expect(arena.quizzes.first.title, 'Java OOP Quiz');
    });
  });
}
