import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/loading_indicator.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchStudents();
    });
  }

  void _showAddStudentModal() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final semCtrl = TextEditingController();
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create student account', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        'Issue a Student ID and password. The student logs in with that ID.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightInk500),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: nameCtrl,
                        label: 'Full name',
                        validator: (v) => Validators.requiredField(v, message: 'Name is required'),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: emailCtrl,
                        label: 'Registered email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: idCtrl,
                        label: 'Student ID',
                        hintText: 'e.g. STU2026100',
                        validator: (v) => Validators.requiredField(v, message: 'Student ID is required'),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: passCtrl,
                        label: 'Temporary password',
                        obscureText: obscure,
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setModal(() => obscure = !obscure),
                        ),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: CustomTextField(controller: deptCtrl, label: 'Department', hintText: 'ECE')),
                          const SizedBox(width: 10),
                          Expanded(child: CustomTextField(controller: yearCtrl, label: 'Year')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(controller: semCtrl, label: 'Semester', keyboardType: TextInputType.number),
                      const SizedBox(height: 18),
                      CustomButton(
                        text: 'Create login credentials',
                        icon: Icons.person_add_rounded,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(ctx);
                          final success = await Provider.of<AdminProvider>(context, listen: false).addStudent(
                            name: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                            studentId: idCtrl.text.trim(),
                            department: deptCtrl.text.trim(),
                            year: yearCtrl.text.trim(),
                            semester: int.tryParse(semCtrl.text) ?? 0,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Student account created. Share the ID and password securely.'
                                  : 'Could not create student. Check for duplicate ID or email.'),
                              backgroundColor: success ? null : AppColors.danger500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.brand500),
            onPressed: _showAddStudentModal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brand500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
        onPressed: _showAddStudentModal,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoadingStudents && admin.students.isEmpty) {
            return const LoadingIndicator(message: 'Loading enrolled students...');
          }

          if (admin.students.isEmpty) {
            return ErrorStateView(
              title: 'No students yet',
              message: 'Create a Student ID and password so the student can sign in.',
              onRetry: () => admin.fetchStudents(),
            );
          }

          final filtered = admin.students.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.name.toLowerCase().contains(q) || s.studentId.toLowerCase().contains(q) || s.email.toLowerCase().contains(q);
          }).toList();

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => admin.fetchStudents(),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or email',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const EmptyStateView(
                    title: 'No students found',
                    message: 'No student matches your search.',
                    icon: Icons.person_search_outlined,
                  )
                else
                  ...filtered.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.brand500,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0] : 'S',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text('${s.studentId} · ${s.department ?? '—'} · ${s.email}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger500, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dctx) => AlertDialog(
                              title: const Text('Remove student'),
                              content: Text('Permanently delete ${s.name} and their login?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(dctx);
                                    await admin.deleteStudent(s);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: AppColors.danger500)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )),
                const SizedBox(height: 72),
              ],
            ),
          );
        },
      ),
    );
  }
}
