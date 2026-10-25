import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/teacher_models.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/stat_progress_bar.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  String _searchQuery = '';
  String _selectedRisk = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherProvider>(context, listen: false).fetchStudents();
    });
  }

  void _openMarksModal(TeacherStudentModel student) {
    final internalCtrl = TextEditingController(text: student.internalMarks.toString());
    final externalCtrl = TextEditingController(text: student.externalMarks.toString());
    final assignCtrl = TextEditingController(text: student.assignmentMarks.toString());
    final quizCtrl = TextEditingController(text: student.quizMarks.toString());
    String selectedSubject = student.subject ?? 'Java Programming';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter Assessment Marks', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${student.name} (${student.studentId})', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightInk500)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: internalCtrl,
                        label: 'Internal (100)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: externalCtrl,
                        label: 'External (100)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: assignCtrl,
                        label: 'Assignment (100)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: quizCtrl,
                        label: 'Quiz (100)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CustomButton(
                  text: 'Save Marks & Recalculate Grade',
                  icon: Icons.check_circle_rounded,
                  onPressed: () async {
                    final internal = num.tryParse(internalCtrl.text) ?? 0;
                    final external = num.tryParse(externalCtrl.text) ?? 0;
                    final assign = num.tryParse(assignCtrl.text) ?? 0;
                    final quiz = num.tryParse(quizCtrl.text) ?? 0;

                    Navigator.pop(ctx);
                    final success = await Provider.of<TeacherProvider>(context, listen: false).submitMarks(
                      studentId: student.studentId,
                      subject: selectedSubject,
                      internal: internal,
                      external: external,
                      assignment: assign,
                      quiz: quiz,
                    );
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marks updated and grade recalculated successfully!')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAttendanceModal(TeacherStudentModel student) {
    final attendedCtrl = TextEditingController(text: '36');
    final totalCtrl = TextEditingController(text: '40');
    String selectedSubject = student.subject ?? 'Communication Systems';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log Student Attendance', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${student.name} (${student.studentId})', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightInk500)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: attendedCtrl,
                      label: 'Classes Attended',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: totalCtrl,
                      label: 'Total Classes Held',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'Update Attendance',
                icon: Icons.calendar_month_rounded,
                onPressed: () async {
                  final attended = int.tryParse(attendedCtrl.text) ?? 0;
                  final total = int.tryParse(totalCtrl.text) ?? 40;

                  Navigator.pop(ctx);
                  final success = await Provider.of<TeacherProvider>(context, listen: false).submitAttendance(
                    studentId: student.studentId,
                    subject: selectedSubject,
                    attended: attended,
                    total: total,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance updated successfully!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students Roster'),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacher, _) {
          if (teacher.isLoadingStudents && teacher.students.isEmpty) {
            return const LoadingIndicator(message: 'Loading enrolled students and live grades...');
          }

          if (teacher.students.isEmpty) {
            return const EmptyStateView(
              title: 'No students found',
              message: 'Student records will appear here once they are enrolled.',
              icon: Icons.people_outline_rounded,
            );
          }

          final allStudents = teacher.students;

          final filtered = allStudents.where((s) {
            final matchesQuery = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.studentId.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesRisk = _selectedRisk == 'All' || s.riskLevel.toLowerCase().contains(_selectedRisk.toLowerCase());
            return matchesQuery && matchesRisk;
          }).toList();

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => teacher.fetchStudents(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search by student name or ID...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Risk Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', _selectedRisk == 'All', () => setState(() => _selectedRisk = 'All')),
                        _filterChip('Low Risk', _selectedRisk == 'Low Risk', () => setState(() => _selectedRisk = 'Low Risk')),
                        _filterChip('Moderate', _selectedRisk == 'Moderate', () => setState(() => _selectedRisk = 'Moderate')),
                        _filterChip('Critical', _selectedRisk == 'Critical', () => setState(() => _selectedRisk = 'Critical')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (filtered.isEmpty)
                    const EmptyStateView(
                      title: 'No matching students found',
                      message: 'Try changing your search query or filter selection.',
                      icon: Icons.person_search_outlined,
                    )
                  else
                    ...filtered.map((s) => _buildStudentRosterCard(s, isDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
        selected: isSelected,
        selectedColor: AppColors.brand500,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildStudentRosterCard(TeacherStudentModel s, bool isDark) {
    final riskColor = AppColors.statusColor(s.riskLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.brand500,
                  child: Text(s.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${s.studentId} · ${s.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    s.riskLevel,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: riskColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: ${s.overall}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Attendance: ${s.attendance}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            StatProgressBar(percentage: s.overall),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Enter Marks', style: TextStyle(fontSize: 12)),
                    onPressed: () => _openMarksModal(s),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: const Text('Attendance', style: TextStyle(fontSize: 12)),
                    onPressed: () => _openAttendanceModal(s),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
