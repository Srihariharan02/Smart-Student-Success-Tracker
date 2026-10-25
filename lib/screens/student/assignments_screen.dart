import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/assignment_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_view.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchAssignments();
    });
  }

  void _showSubmitModal(AssignmentModel assignment) {
    final textCtrl = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submit Assignment', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(assignment.title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightInk500)),
              const SizedBox(height: 14),
              CustomTextField(
                controller: textCtrl,
                label: 'Assignment Response / Solution Notes',
                hintText: 'Enter your completed assignment response or GitHub repository URL...',
                maxLines: 4,
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'Confirm & Submit',
                icon: Icons.upload_file_rounded,
                onPressed: () async {
                  if (textCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final success = await Provider.of<StudentProvider>(context, listen: false).submitAssignment(
                    assignment.id,
                    textCtrl.text.trim(),
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assignment submitted successfully!')),
                    );
                  }
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
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, student, _) {
          if (student.isLoadingAssignments && student.assignments.isEmpty) {
            return const LoadingIndicator(message: 'Loading course assignments...');
          }

          final allAssignments = student.assignments;
          final filtered = _selectedFilter == 'All'
              ? allAssignments
              : allAssignments.where((a) => a.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => student.fetchAssignments(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', _selectedFilter == 'All', () => setState(() => _selectedFilter = 'All')),
                        _filterChip('Active', _selectedFilter == 'Active', () => setState(() => _selectedFilter = 'Active')),
                        _filterChip('Due Soon', _selectedFilter == 'Due Soon', () => setState(() => _selectedFilter = 'Due Soon')),
                        _filterChip('Completed', _selectedFilter == 'Completed', () => setState(() => _selectedFilter = 'Completed')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (filtered.isEmpty)
                    const EmptyStateView(
                      title: 'No assignments found',
                      message: 'You have no assignments matching this status.',
                      icon: Icons.assignment_outlined,
                    )
                  else
                    ...filtered.map((a) => _buildAssignmentCard(a, isDark)),
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

  Widget _buildAssignmentCard(AssignmentModel a, bool isDark) {
    final statusColor = AppColors.statusColor(a.status);

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
                  child: Text(
                    a.title,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    a.status,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${a.subject} · Faculty: ${a.faculty}',
              style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
            ),
            if (a.description != null && a.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                a.description!,
                style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk700 : AppColors.lightInk700),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, size: 14, color: AppColors.warn500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Due: ${a.dueDate}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!a.isCompleted)
                  CustomButton(
                    text: 'Submit',
                    icon: Icons.upload_rounded,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    onPressed: () => _showSubmitModal(a),
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success500),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success500),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
