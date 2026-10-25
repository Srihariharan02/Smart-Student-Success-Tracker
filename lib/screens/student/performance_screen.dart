import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/performance_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/stat_progress_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_view.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchPerformance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Breakdown'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, student, _) {
          if (student.isLoadingPerformance && student.performanceSubjects.isEmpty) {
            return const LoadingIndicator(message: 'Calculating subject marks & grades...');
          }

          if (student.performanceError != null && student.performanceSubjects.isEmpty) {
            return ErrorStateView(
              message: student.performanceError,
              onRetry: () => student.fetchPerformance(),
            );
          }

          final subjects = student.performanceSubjects;

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => student.fetchPerformance(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject-Wise Marks & Grade Analytics',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Computed live by backend performance service.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject Comparison Bar Chart
                  if (subjects.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subject Score Comparison',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: _buildBarChart(subjects, isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Subject Cards (Mobile Redesign of Table)
                  Text(
                    'Subject Detail Summary',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...subjects.map((sub) => _buildSubjectCard(sub, isDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChart(List<SubjectPerformanceModel> subjects, bool isDark) {
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < subjects.length; i++) {
      final sub = subjects[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sub.overall.toDouble(),
              color: AppColors.scoreColor(sub.overall),
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (val) => FlLine(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 25,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}',
                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < subjects.length) {
                  final name = subjects[idx].name.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      name.length > 5 ? name.substring(0, 5) : name,
                      style: TextStyle(fontSize: 9, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        maxY: 100,
        barGroups: groups,
      ),
    );
  }

  Widget _buildSubjectCard(SubjectPerformanceModel sub, bool isDark) {
    final gradeColor = AppColors.scoreColor(sub.overall);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
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
                        sub.name,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Faculty: ${sub.faculty}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Grade: ${sub.grade}',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Scores Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInk100 : AppColors.lightInk100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _scoreItem('Internal', '${sub.internalMarks}%', isDark),
                  _divider(isDark),
                  _scoreItem('Assign', '${sub.assignmentMarks}%', isDark),
                  _divider(isDark),
                  _scoreItem('Quiz', '${sub.quizMarks}%', isDark),
                  _divider(isDark),
                  _scoreItem('Attendance', '${sub.attendance}%', isDark),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Weighted Score',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkInk700 : AppColors.lightInk700,
                  ),
                ),
                Text(
                  '${sub.overall}%',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            StatProgressBar(percentage: sub.overall),
          ],
        ),
      ),
    );
  }

  Widget _scoreItem(String label, String val, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 20,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
