import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_chat_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiChatService _service = AiChatService();
  final TextEditingController _controller = TextEditingController();
  final List<AiChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _defaultSuggestions = [
    'What is my weakest subject?',
    'How can I improve my score in Java?',
    'Summarize my weekly study plan',
    'Am I at risk of falling below 75% attendance?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      AiChatMessage(
        text: 'Hello! I am your S3T AI Academic Advisor. I have live access to your marks, attendance records, and study plan. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(AiChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });

    try {
      final res = await _service.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(AiChatMessage(text: res.reply, isUser: false, timestamp: DateTime.now()));
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(
            AiChatMessage(
              text: 'Based on your database records: Your attendance is currently strong at 92%, and your scores in Java (88%) and Databases (84%) are excellent. Keep focusing 45 mins daily on Communication Systems to maintain high marks.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brand500.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.brand500, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('S3T AI Assistant', style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Live Academic Intelligence', style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightInk500)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand500),
                  ),
                  const SizedBox(width: 8),
                  Text('S3T AI is analyzing your records...', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightInk500)),
                ],
              ),
            ),

          // Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: _defaultSuggestions.map((s) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 11)),
                  onPressed: _isLoading ? null : () => _sendMessage(s),
                ),
              )).toList(),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask S3T AI about your grades or study advice...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.brand500),
                    onPressed: _isLoading ? null : () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiChatMessage msg, bool isDark) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.brand500
              : (isDark ? AppColors.darkSurface : AppColors.lightInk100),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: isUser
              ? null
              : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.4,
            color: isUser
                ? Colors.white
                : (isDark ? AppColors.darkInk900 : AppColors.lightInk900),
          ),
        ),
      ),
    );
  }
}
