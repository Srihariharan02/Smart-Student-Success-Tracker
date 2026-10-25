import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_view.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const TeacherDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherProvider>(context, listen: false).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);
    final auth = Provider.of<AuthProvider>(context);

    return Consumer<TeacherProvider>(
      builder: (context, teacher, _) {
        if (teacher.isLoadingDashboard && teacher.dashboard == null) {
          return const LoadingIndicator(message: 'Loading class records & analytics...');
        }

        if (teacher.dashboardError != null && teacher.dashboard == null) {
          return ErrorStateView(
            message: teacher.dashboardError,
            onRetry: () => teacher.fetchDashboard(),
          );
        }

        final d = teacher.dashboard;
        if (d == null) {
          return ErrorStateView(
            message: 'No class data is available yet.',
            onRetry: () => teacher.fetchDashboard(),
          );
        }

        return RefreshIndicator(
          color: AppColors.brand500,
          onRefresh: () => teacher.fetchDashboard(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${auth.user?.name ?? 'Dr. Kumar'} 👨‍🏫',
                  style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Faculty Dashboard · Academic Progress & Intervention Center',
                  style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                ),
                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: Responsive.gridCount(context, min: 2, max: 2),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.22,
                  children: [
                    KpiCard(
                      label: 'Total Enrolled',
                      value: '${d.totalStudents}',
                      subtitle: 'Active students',
                      icon: Icons.people_outline_rounded,
                      tone: 'brand',
                    ),
                    KpiCard(
                      label: 'Class Average',
                      value: '${d.classAverage}%',
                      subtitle: 'Overall score',
                      icon: Icons.analytics_outlined,
                      tone: 'success',
                    ),
                    KpiCard(
                      label: 'Attendance Rate',
                      value: '${d.attendanceRate}%',
                      subtitle: 'Average attendance',
                      icon: Icons.calendar_today_outlined,
                      tone: 'blue',
                    ),
                    KpiCard(
                      label: 'At-Risk Students',
                      value: '${d.atRiskCount}',
                      subtitle: 'Need intervention',
                      icon: Icons.warning_amber_rounded,
                      tone: d.atRiskCount > 0 ? 'danger' : 'success',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Urgent At-Risk Student Alert Section
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
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_rounded, color: AppColors.danger500, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'At-Risk Students Requiring Review',
                                      style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(1); // Students tab
                                }
                              },
                              child: Text('View Roster', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brand500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (d.atRiskStudents.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'All students are currently performing above risk thresholds.',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.success500),
                            ),
                          )
                        else
                          ...d.atRiskStudents.map((s) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger500.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.danger500.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.danger500,
                                  child: Text(s.name[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.bold)),
                                      Text('${s.studentId} · Score: ${s.overall}% · Att: ${s.attendance}%', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger500,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(s.riskLevel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
