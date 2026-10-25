import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/loading_indicator.dart';

class ParentReportScreen extends StatefulWidget {
  const ParentReportScreen({super.key});

  @override
  State<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final student = Provider.of<StudentProvider>(context, listen: false);
      if (student.dashboard == null) {
        student.fetchDashboard();
      }
    });
  }

  Future<void> _share(StudentProvider student) async {
    final d = student.dashboard;
    if (d == null) return;
    final buffer = StringBuffer()
      ..writeln('Smart Student Success Tracker')
      ..writeln('Parent Academic Report')
      ..writeln('Student: ${d.name}')
      ..writeln('ID: ${d.studentId}')
      ..writeln('Overall: ${d.overallPercentage}%')
      ..writeln('Attendance: ${d.attendancePercentage}%')
      ..writeln('Risk: ${d.academicRisk}')
      ..writeln('Subjects:');
    for (final s in d.subjects) {
      buffer.writeln(' - ${s.name}: ${s.overall}% (${s.grade})');
    }
    await Share.share(buffer.toString(), subject: 'SSST Parent Academic Report');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Academic Report'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, student, _) {
          if (student.isLoadingDashboard && student.dashboard == null) {
            return const LoadingIndicator(message: 'Preparing parent report...');
          }
          if (student.dashboardError != null && student.dashboard == null) {
            return ErrorStateView(
              title: 'Could not load report',
              message: student.dashboardError,
              onRetry: () => student.fetchDashboard(),
            );
          }
          final d = student.dashboard;
          if (d == null) {
            return ErrorStateView(
              title: 'No report data',
              message: 'Academic records are not available yet.',
              onRetry: () => student.fetchDashboard(),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.school_rounded, color: AppColors.brand500, size: 36),
                          const SizedBox(height: 6),
                          Text(
                            'Smart Student Success Tracker',
                            style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Student Progress Report',
                            style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 28),
                    _detailRow('Student Name:', d.name, isDark),
                    _detailRow('Student ID:', d.studentId, isDark),
                    _detailRow('Academic Period:', 'Semester ${d.semester} (${d.year})', isDark),
                    _detailRow('Overall Percentage:', '${d.overallPercentage}%', isDark, isBold: true),
                    _detailRow('Attendance Rate:', '${d.attendancePercentage}%', isDark),
                    _detailRow('Academic Risk Level:', d.academicRisk, isDark),
                    const Divider(height: 28),
                    Text('Subject Evaluation', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...d.subjects.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(s.name, style: GoogleFonts.inter(fontSize: 12))),
                          Text('${s.overall}% (Grade ${s.grade})', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Share report',
                      icon: Icons.share_rounded,
                      onPressed: () => _share(student),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
