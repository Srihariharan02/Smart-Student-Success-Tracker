import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student_dashboard_model.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/stat_progress_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_view.dart';

class StudentDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const StudentDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Consumer2<AuthProvider, StudentProvider>(
      builder: (context, auth, student, _) {
        if (student.isLoadingDashboard && student.dashboard == null) {
          return const Scaffold(body: LoadingIndicator(message: 'Loading live academic records...'));
        }

        if (student.dashboardError != null && student.dashboard == null) {
          return Scaffold(
            body: ErrorStateView(
              title: 'Could not connect to SSST backend',
              message: student.dashboardError,
              onRetry: () => student.fetchDashboard(),
            ),
          );
        }

        final d = student.dashboard;
        if (d == null) return const Scaffold(body: SizedBox.shrink());

        final firstName = d.name.split(' ').first;

        return RefreshIndicator(
          color: AppColors.brand500,
          onRefresh: () => student.fetchDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile & Year Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Day, $firstName 👋',
                            style: GoogleFonts.lexend(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Here's your live academic overview",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brand500.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            d.studentId,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brand500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success500.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Sem ${d.semester}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 6 KPI Metric Cards Grid
                GridView.count(
                  crossAxisCount: Responsive.gridCount(context, min: 2, max: 3),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.22,
                  children: [
                    KpiCard(
                      label: 'Overall Score',
                      value: '${d.overallPercentage}%',
                      subtitle: 'Status: ${d.status}',
                      icon: Icons.trending_up_rounded,
                      tone: 'brand',
                    ),
                    KpiCard(
                      label: 'Attendance',
                      value: '${d.attendancePercentage}%',
                      subtitle: 'Live Record',
                      icon: Icons.calendar_today_rounded,
                      tone: 'blue',
                    ),
                    KpiCard(
                      label: 'Average Marks',
                      value: '${d.averageMarks}%',
                      subtitle: '${d.subjects.length} Subjects',
                      icon: Icons.military_tech_rounded,
                      tone: 'success',
                    ),
                    KpiCard(
                      label: 'Assignments',
                      value: '${d.assignmentCompletion}%',
                      subtitle: 'Completion rate',
                      icon: Icons.assignment_turned_in_rounded,
                      tone: 'success',
                    ),
                    KpiCard(
                      label: 'Quiz Arena',
                      value: '${d.quizPerformance}%',
                      subtitle: 'Last attempts',
                      icon: Icons.sports_esports_rounded,
                      tone: 'warn',
                    ),
                    KpiCard(
                      label: 'Academic Risk',
                      value: d.academicRisk,
                      subtitle: 'AI Risk Engine',
                      icon: Icons.shield_outlined,
                      tone: d.academicRisk.toLowerCase().contains('low') ? 'success' : 'danger',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Academic Trend Chart Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Academic Performance Trend',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success500.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '↑ Live Progression',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Overall performance across completed semesters',
                          style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: _buildTrendLineChart(d.trendData, isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Subject Snapshot Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subject Snapshot',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(1); // Go to Performance tab
                                } else {
                                  Navigator.pushNamed(context, AppRoutes.studentPerformance);
                                }
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                              child: Text('View all', style: GoogleFonts.inter(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...d.subjects.take(4).map((sub) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sub.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkInk700 : AppColors.lightInk700),
                                    ),
                                  ),
                                  Text(
                                    '${sub.overall}%',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkInk900 : AppColors.lightInk900),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              StatProgressBar(percentage: sub.overall),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // AI Insights Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.brand500),
                            const SizedBox(width: 8),
                            Text(
                              'AI Academic Insights',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (d.insights.strengths.isNotEmpty)
                          _buildInsightRow(
                            icon: Icons.trending_up_rounded,
                            label: 'Strength',
                            tone: 'success',
                            text: d.insights.strengths.first,
                            isDark: isDark,
                          ),
                        if (d.insights.weakAreas.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInsightRow(
                            icon: Icons.trending_down_rounded,
                            label: 'Weak Area',
                            tone: 'danger',
                            text: d.insights.weakAreas.first,
                            isDark: isDark,
                          ),
                        ],
                        if (d.insights.recommendations.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInsightRow(
                            icon: Icons.lightbulb_outline_rounded,
                            label: 'Recommendation',
                            tone: 'warn',
                            text: d.insights.recommendations.first,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Today's Study Plan Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Today's Study Plan",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(2); // Go to Study Planner tab
                                } else {
                                  Navigator.pushNamed(context, AppRoutes.studentPlanner);
                                }
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                              child: Text('Open Planner', style: GoogleFonts.inter(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (student.tasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'No study tasks scheduled for today.',
                              style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                            ),
                          )
                        else
                          ...student.tasks.take(3).map((task) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: task.isDone,
                                    activeColor: AppColors.brand500,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (_) => student.toggleTask(task.id),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    task.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                                      color: task.isDone
                                          ? (isDark ? AppColors.darkInk500 : AppColors.lightInk500)
                                          : (isDark ? AppColors.darkInk900 : AppColors.lightInk900),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${task.minutes}m',
                                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendLineChart(TrendDataModel trend, bool isDark) {
    if (trend.values.isEmpty) {
      return Center(
        child: Text(
          'No trend data yet',
          style: TextStyle(color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
        ),
      );
    }
    final spots = <FlSpot>[];
    for (int i = 0; i < trend.values.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend.values[i]));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
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
              reservedSize: 32,
              interval: 15,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}%',
                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < trend.labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      trend.labels[idx],
                      style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 40,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.brand500,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.brand500,
                strokeWidth: 2,
                strokeColor: isDark ? AppColors.darkSurface : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.brand500.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String label,
    required String tone,
    required String text,
    required bool isDark,
  }) {
    Color color;
    switch (tone) {
      case 'success':
        color = AppColors.success500;
        break;
      case 'danger':
        color = AppColors.danger500;
        break;
      default:
        color = AppColors.warn500;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInk100 : AppColors.lightInk100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.darkInk700 : AppColors.lightInk700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
