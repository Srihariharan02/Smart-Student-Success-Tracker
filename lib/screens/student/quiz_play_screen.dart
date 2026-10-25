import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stat_progress_bar.dart';

class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key});

  void _showResultDialog(BuildContext context, QuizProvider quiz) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final score = quiz.finalScore ?? 80;
        final xp = quiz.xpEarned ?? 20;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.success500.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.success500, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Quiz Completed!',
                style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'You scored $score%',
                style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brand500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$xp XP Earned ⚡',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                ),
              ),
              if (quiz.leveledUp) ...[
                const SizedBox(height: 10),
                Text(
                  '🎉 Congratulations! You reached Level Up!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.success500, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(
                text: 'Back to Arena',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<QuizProvider>(
      builder: (context, quiz, _) {
        final deck = quiz.currentDeck;
        if (deck == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const Center(child: Text('No active quiz')),
          );
        }

        final questions = deck.questions;
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(deck.title)),
            body: const Center(child: Text('This quiz has no questions yet.')),
          );
        }

        final currentIdx = quiz.currentQuestionIndex.clamp(0, questions.length - 1);
        final currentQ = questions[currentIdx];
        final selectedOption = quiz.selectedAnswers[currentQ.id];
        final progress = ((currentIdx + 1) / questions.length) * 100;
        final isLast = currentIdx == questions.length - 1;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Leave quiz?'),
                content: const Text('Your current answers will be lost if you exit now.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
                ],
              ),
            );
            if (leave == true && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
          appBar: AppBar(
            title: Text(deck.title),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    '${currentIdx + 1} / ${questions.length}',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatProgressBar(percentage: progress, height: 6, color: AppColors.brand500),
                const SizedBox(height: 18),

                // Question Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUESTION ${currentIdx + 1}',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brand500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentQ.question,
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Options List
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQ.options.length,
                    itemBuilder: (context, idx) {
                      final isSelected = selectedOption == idx;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => quiz.selectAnswer(currentQ.id, idx),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brand500.withValues(alpha: isDark ? 0.25 : 0.1)
                                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.brand500 : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.brand500 : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.brand500 : (isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + idx),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : (isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentQ.options[idx],
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation Controls
                Row(
                  children: [
                    if (currentIdx > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Previous',
                          variant: ButtonVariant.outline,
                          onPressed: () => quiz.previousQuestion(),
                        ),
                      ),
                    if (currentIdx > 0) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: isLast ? 'Submit Quiz' : 'Next Question',
                        icon: isLast ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                        isLoading: quiz.isSubmitting,
                        onPressed: () async {
                          if (isLast) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Submit quiz?'),
                                content: const Text('You cannot change answers after submitting.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Review')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
                                ],
                              ),
                            );
                            if (confirm != true) return;
                            final success = await quiz.submitQuiz();
                            if (success && context.mounted) {
                              _showResultDialog(context, quiz);
                            }
                          } else {
                            quiz.nextQuestion();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}
