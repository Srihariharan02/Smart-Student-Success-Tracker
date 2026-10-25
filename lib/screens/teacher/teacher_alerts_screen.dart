import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/teacher_models.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_view.dart';

class TeacherAlertsScreen extends StatefulWidget {
  const TeacherAlertsScreen({super.key});

  @override
  State<TeacherAlertsScreen> createState() => _TeacherAlertsScreenState();
}

class _TeacherAlertsScreenState extends State<TeacherAlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherProvider>(context, listen: false).fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Intervention Alerts'),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacher, _) {
          if (teacher.isLoadingAlerts && teacher.alerts.isEmpty) {
            return const LoadingIndicator(message: 'Checking intervention warnings...');
          }

          final alerts = teacher.alerts.isNotEmpty
              ? teacher.alerts
              : [
                  InterventionAlertModel(
                    id: 'ALT001',
                    studentName: 'Karthik Raja',
                    studentId: 'STU2026004',
                    subject: 'Communication Systems',
                    severity: 'Critical',
                    issue: 'Declining score trajectory across last 2 quizzes & low attendance (62%)',
                    timestamp: '2 hours ago',
                    isResolved: false,
                  ),
                  InterventionAlertModel(
                    id: 'ALT002',
                    studentName: 'Rohan Verma',
                    studentId: 'STU2026003',
                    subject: 'Database Systems',
                    severity: 'Warning',
                    issue: 'Assignment 3 overdue by 3 days and quiz score dropped to 60%',
                    timestamp: '1 day ago',
                    isResolved: false,
                  ),
                ];

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => teacher.fetchAlerts(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Student Intervention Flags',
                    style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Early-warning system triggers when student score or attendance drops below critical thresholds.',
                    style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                  ),
                  const SizedBox(height: 16),

                  if (alerts.isEmpty)
                    const EmptyStateView(
                      title: 'No pending alerts',
                      message: 'No student intervention alerts requiring review.',
                      icon: Icons.check_circle_outline_rounded,
                    )
                  else
                    ...alerts.map((alert) => _buildAlertCard(alert, teacher, isDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(InterventionAlertModel alert, TeacherProvider teacher, bool isDark) {
    final isCritical = alert.severity.toLowerCase().contains('crit');
    final color = isCritical ? AppColors.danger500 : AppColors.warn500;

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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(Icons.warning_amber_rounded, size: 18, color: color),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.severity.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${alert.studentId} · Subject: ${alert.subject}',
              style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
            ),
            const SizedBox(height: 8),
            Text(
              alert.issue,
              style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: isDark ? AppColors.darkInk700 : AppColors.lightInk700),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  alert.timestamp,
                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                ),
                if (!alert.isResolved)
                  CustomButton(
                    text: 'Resolve Alert',
                    icon: Icons.done_all_rounded,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    onPressed: () async {
                      await teacher.resolveAlert(alert.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Intervention alert marked as resolved.')),
                        );
                      }
                    },
                  )
                else
                  Text(
                    'Resolved ✓',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
