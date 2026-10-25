import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_view.dart';

class AdminSubjectsScreen extends StatefulWidget {
  const AdminSubjectsScreen({super.key});

  @override
  State<AdminSubjectsScreen> createState() => _AdminSubjectsScreenState();
}

class _AdminSubjectsScreenState extends State<AdminSubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchSubjects();
    });
  }

  void _showAddSubjectModal() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'ECE');
    final semCtrl = TextEditingController(text: '8');
    final creditsCtrl = TextEditingController(text: '4');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
              Text('Create New Academic Course', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              CustomTextField(controller: nameCtrl, label: 'Subject Name', hintText: 'e.g. Embedded Systems'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: codeCtrl, label: 'Course Code', hintText: 'EC801')),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: deptCtrl, label: 'Department')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: semCtrl, label: 'Semester', keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: creditsCtrl, label: 'Credits', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'Add to Curriculum',
                icon: Icons.book_rounded,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final success = await Provider.of<AdminProvider>(context, listen: false).addSubject(
                    name: nameCtrl.text.trim(),
                    code: codeCtrl.text.trim(),
                    department: deptCtrl.text.trim(),
                    semester: int.tryParse(semCtrl.text) ?? 8,
                    credits: int.tryParse(creditsCtrl.text) ?? 4,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Course added successfully to database!')),
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
    final horizontalPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: AppColors.brand500),
            onPressed: _showAddSubjectModal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brand500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('Add Course'),
        onPressed: _showAddSubjectModal,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoadingSubjects && admin.subjects.isEmpty) {
            return const LoadingIndicator(message: 'Loading courses from database...');
          }

          final subjects = admin.subjects;

          if (subjects.isEmpty) {
            return const EmptyStateView(
              title: 'No courses registered',
              message: 'Add a new subject to course catalog.',
              icon: Icons.menu_book_outlined,
            );
          }

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => admin.fetchSubjects(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              itemCount: subjects.length,
              itemBuilder: (context, idx) {
                final s = subjects[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.brand500.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.book_rounded, color: AppColors.brand500, size: 20),
                    ),
                    title: Text(s.name, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('${s.code ?? 'Course'} · ${s.department ?? 'Dept'} Sem ${s.semester ?? 8}\nFaculty: ${s.facultyName ?? 'Assigned'}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.blue500.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text('${s.credits ?? 4} Credits', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.blue500)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
