import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiChatService {
  final ApiClient _client = ApiClient();

  Future<({String reply, List<String> suggestions})> sendMessage(String message) async {
    final response = await _client.post(
      ApiConstants.studentAiChat,
      body: {'message': message},
    );

    final data = response as Map<String, dynamic>;
    final reply = data['reply'] ?? data['message'] ?? 'I have reviewed your academic records.';
    final rawSuggestions = data['suggestions'] is List ? (data['suggestions'] as List).map((e) => e.toString()).toList() : <String>[];

    return (reply: reply.toString(), suggestions: rawSuggestions);
  }
}
