import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/quiz_model.dart';

class QuizService {
  final ApiClient _client = ApiClient();

  Future<QuizArenaDataModel> getQuizArena() async {
    final response = await _client.get(ApiConstants.quizzes);
    return QuizArenaDataModel.fromJson(response as Map<String, dynamic>);
  }

  Future<({num score, int xpEarned, String message, bool leveledUp, int newLevel})> attemptQuiz(int quizId, Map<int, int> answers) async {
    final formattedAnswers = answers.map((k, v) => MapEntry(k.toString(), v));
    final response = await _client.post(
      '${ApiConstants.quizzes}/$quizId/attempt',
      body: {'answers': formattedAnswers},
    );

    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final num score = data['score'] is num ? (data['score'] as num) : (num.tryParse(data['score']?.toString() ?? '') ?? 0);
    final int xp = data['xp_earned'] is int ? (data['xp_earned'] as int) : (int.tryParse(data['xp_earned']?.toString() ?? '') ?? 10);
    final String msg = data['message']?.toString() ?? 'Quiz completed!';
    final bool lvlUp = data['leveled_up'] == true;
    final int newLvl = data['new_level'] is int ? (data['new_level'] as int) : (int.tryParse(data['new_level']?.toString() ?? '') ?? 1);

    return (score: score, xpEarned: xp, message: msg, leveledUp: lvlUp, newLevel: newLvl);
  }
}
