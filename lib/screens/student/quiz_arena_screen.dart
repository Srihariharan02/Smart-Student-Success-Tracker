import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/quiz_model.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/stat_progress_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_view.dart';
import 'quiz_play_screen.dart';

class QuizArenaScreen extends StatefulWidget {
  const QuizArenaScreen({super.key});

  @override
  State<QuizArenaScreen> createState() => _QuizArenaScreenState();
}

class _QuizArenaScreenState extends State<QuizArenaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizArena();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Arena & Gamification'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quiz, _) {
          if (quiz.isLoadingArena && quiz.arenaData == null) {
            return const LoadingIndicator(message: 'Loading quiz decks & gamification XP...');
          }

          if (quiz.arenaError != null && quiz.arenaData == null) {
            return ErrorStateView(
              message: quiz.arenaError,
              onRetry: () => quiz.fetchQuizArena(),
            );
          }

          final arena = quiz.arenaData;
          if (arena == null) return const SizedBox.shrink();

          final g = arena.gamification;

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => quiz.fetchQuizArena(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gamification Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand500.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.military_tech_rounded, color: Colors.amberAccent, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Level ${g.level}',
                                            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text('🔥', style: TextStyle(fontSize: 13)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${g.streak} Day Streak',
                                            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${g.xp} XP',
                              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'XP to Next Level',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                            ),
                            Text(
                              '${g.xp} / ${g.nextLevelXp} XP',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        StatProgressBar(
                          percentage: g.nextLevelXp > 0 ? (g.xp / g.nextLevelXp) * 100 : 50,
                          height: 8,
                          color: Colors.amberAccent,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: g.badges.map((b) => Chip(
                            label: Text(b, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Available Subject Quizzes',
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...arena.quizzes.map((deck) => _buildDeckCard(deck, isDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeckCard(QuizDeckModel deck, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.title,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deck.subject,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brand500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+10 XP / Q',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brand500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _infoBadge(Icons.help_outline_rounded, '${deck.questionsCount} Questions', isDark),
                _infoBadge(Icons.timer_outlined, '${deck.durationMinutes} mins', isDark),
                if (deck.lastScore != null)
                  _infoBadge(Icons.score_outlined, 'Score: ${deck.lastScore}%', isDark, tone: 'success'),
              ],
            ),
            const SizedBox(height: 14),
            CustomButton(
              text: 'Start Quiz Now',
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                final qProvider = Provider.of<QuizProvider>(context, listen: false);
                qProvider.startQuiz(deck);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, bool isDark, {String tone = 'normal'}) {
    Color color = isDark ? AppColors.darkInk500 : AppColors.lightInk500;
    if (tone == 'success') color = AppColors.success500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInk100 : AppColors.lightInk100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
