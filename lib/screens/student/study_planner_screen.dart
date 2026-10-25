import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/study_task_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/stat_progress_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_view.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchPlanner();
    });
  }

  void _showAddTaskModal() {
    final textCtrl = TextEditingController();
    final minutesCtrl = TextEditingController(text: '45');
    String selectedSubject = 'Java Programming';
    String selectedDay = 'Monday';
    String selectedPriority = 'High';

    final subjects = ['Java Programming', 'Database Systems', 'Communication Systems', 'Software Engineering', 'Mathematics'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final priorities = ['High', 'Medium', 'Low'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Study Task',
                          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: textCtrl,
                      label: 'Task Description',
                      hintText: 'e.g. Review Dijkstra Algorithm problems',
                    ),
                    const SizedBox(height: 12),
                    Text('Subject', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSubject,
                      items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) => setModalState(() => selectedSubject = val!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Day', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedDay,
                                items: days.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) => setModalState(() => selectedDay = val!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: minutesCtrl,
                            label: 'Minutes',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Priority', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      items: priorities.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) => setModalState(() => selectedPriority = val!),
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: 'Add to Schedule',
                      icon: Icons.add_task_rounded,
                      onPressed: () async {
                        if (textCtrl.text.trim().isEmpty) return;
                        final minutes = int.tryParse(minutesCtrl.text) ?? 30;
                        Navigator.pop(ctx);
                        await Provider.of<StudentProvider>(context, listen: false).addTask(
                          text: textCtrl.text.trim(),
                          subject: selectedSubject,
                          day: selectedDay,
                          minutes: minutes,
                          priority: selectedPriority,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
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
        title: const Text('AI Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.brand500),
            onPressed: _showAddTaskModal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brand500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        onPressed: _showAddTaskModal,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, student, _) {
          if (student.isLoadingPlanner && student.tasks.isEmpty) {
            return const LoadingIndicator(message: 'Loading your personalized study plan...');
          }

          final filteredTasks = _selectedFilter == 'All'
              ? student.tasks
              : student.tasks.where((t) => t.subject == _selectedFilter || t.day == _selectedFilter).toList();

          final subjects = student.tasks.map((t) => t.subject).toSet().toList();

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => student.fetchPlanner(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly Progress Card
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
                                'Weekly Completion Rate',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                                ),
                              ),
                              Text(
                                '${student.completionPercentage}% Done',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brand500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          StatProgressBar(
                            percentage: student.completionPercentage,
                            height: 9,
                            color: AppColors.brand500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority Subject Recommendations
                  if (student.priorities.isNotEmpty) ...[
                    Text(
                      'AI Performance Recommendations',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...student.priorities.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warn500.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.level,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warn500),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.subject,
                                  style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  p.recommendation,
                                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                  ],

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', _selectedFilter == 'All', () => setState(() => _selectedFilter = 'All')),
                        ...subjects.map((s) => _filterChip(s, _selectedFilter == s, () => setState(() => _selectedFilter = s))),
                        ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((d) => _filterChip(d, _selectedFilter == d, () => setState(() => _selectedFilter = d))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Task List
                  if (filteredTasks.isEmpty)
                    EmptyStateView(
                      title: 'No study tasks found',
                      message: 'Add a new task to organize your weekly study plan.',
                      icon: Icons.calendar_today_outlined,
                      action: CustomButton(
                        text: 'Add First Task',
                        fullWidth: false,
                        onPressed: _showAddTaskModal,
                      ),
                    )
                  else
                    ...filteredTasks.map((t) => _buildTaskItem(t, student, isDark)),
                  const SizedBox(height: 60), // FAB spacing
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

  Widget _buildTaskItem(StudyTaskModel t, StudentProvider student, bool isDark) {
    Color priorityColor = AppColors.brand500;
    if (t.priority.toLowerCase() == 'high') priorityColor = AppColors.danger500;
    if (t.priority.toLowerCase() == 'medium') priorityColor = AppColors.warn500;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: t.isDone,
              activeColor: AppColors.brand500,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (_) => student.toggleTask(t.id),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.text,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: t.isDone ? TextDecoration.lineThrough : null,
                      color: t.isDone
                          ? (isDark ? AppColors.darkInk500 : AppColors.lightInk500)
                          : (isDark ? AppColors.darkInk900 : AppColors.lightInk900),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${t.subject} · ${t.day}',
                        style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t.priority,
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: priorityColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${t.minutes}m',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger500),
              onPressed: () => student.deleteTask(t.id),
            ),
          ],
        ),
      ),
    );
  }
}
