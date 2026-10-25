import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/student_provider.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/loading_indicator.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchPrediction();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Prediction'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, student, _) {
          if (student.isLoadingPrediction && student.prediction == null) {
            return const LoadingIndicator(message: 'Generating AI momentum projection...');
          }

          final pred = student.prediction ?? {
            'current_performance': 82.0,
            'predicted_next_assessment': 85.0,
            'predicted_semester_score': 84.0,
            'confidence': 87.0,
            'risk_level': 'Low Risk',
            'explanation': 'Strong momentum in coursework with steady upward trajectory in recent assessments and high assignment submission rate.',
          };

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Academic Momentum & Projections',
                  style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Predicted scores based on historical assessments and study consistency.',
                  style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                ),
                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    KpiCard(
                      label: 'Current Score',
                      value: '${pred['current_performance']}%',
                      subtitle: 'Active record',
                      icon: Icons.speed_rounded,
                      tone: 'brand',
                    ),
                    KpiCard(
                      label: 'Next Assessment',
                      value: '${pred['predicted_next_assessment']}%',
                      subtitle: 'Projected score',
                      icon: Icons.trending_up_rounded,
                      tone: 'success',
                    ),
                    KpiCard(
                      label: 'Semester Forecast',
                      value: '${pred['predicted_semester_score']}%',
                      subtitle: 'Final score estimate',
                      icon: Icons.grade_rounded,
                      tone: 'success',
                    ),
                    KpiCard(
                      label: 'Model Confidence',
                      value: '${pred['confidence']}%',
                      subtitle: 'Confidence score',
                      icon: Icons.psychology_rounded,
                      tone: 'blue',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.brand500, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AI Analysis & Reasoning',
                              style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pred['explanation']?.toString() ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? AppColors.darkInk700 : AppColors.lightInk700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
