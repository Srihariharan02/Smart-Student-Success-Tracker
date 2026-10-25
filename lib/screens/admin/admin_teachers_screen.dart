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
import '../../widgets/loading_indicator.dart';

class AdminTeachersScreen extends StatefulWidget {
  const AdminTeachersScreen({super.key});

  @override
  State<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchTeachers();
    });
  }

  void _showAddTeacherModal() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final desigCtrl = TextEditingController();
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
                      Text('Create faculty account', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        'Teachers sign in with registered email, not Teacher ID.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightInk500),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: nameCtrl,
                        label: 'Faculty name',
                        validator: (v) => Validators.requiredField(v, message: 'Name is required'),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: emailCtrl,
                        label: 'Registered email (login)',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: idCtrl,
                        label: 'Teacher ID',
                        hintText: 'e.g. TCH201',
                        validator: (v) => Validators.requiredField(v, message: 'Teacher ID is required'),
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
                      CustomTextField(controller: deptCtrl, label: 'Department'),
                      const SizedBox(height: 10),
                      CustomTextField(controller: desigCtrl, label: 'Designation'),
                      const SizedBox(height: 18),
                      CustomButton(
                        text: 'Create faculty login',
                        icon: Icons.person_add_rounded,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(ctx);
                          final success = await Provider.of<AdminProvider>(context, listen: false).addTeacher(
                            name: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                            department: deptCtrl.text.trim(),
                            designation: desigCtrl.text.trim(),
                            teacherId: idCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Faculty account created. They log in with registered email.'
                                  : 'Could not create faculty. Check duplicate ID or email.'),
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
        title: const Text('Faculty Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.brand500),
            onPressed: _showAddTeacherModal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brand500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Faculty'),
        onPressed: _showAddTeacherModal,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoadingTeachers && admin.teachers.isEmpty) {
            return const LoadingIndicator(message: 'Loading faculty directory...');
          }

          if (admin.teachers.isEmpty) {
            return const EmptyStateView(
              title: 'No faculty members found',
              message: 'Create a faculty account with email and password.',
              icon: Icons.school_outlined,
            );
          }

          final teachers = admin.teachers.where((t) {
            final q = _searchQuery.toLowerCase();
            return t.name.toLowerCase().contains(q) ||
                t.email.toLowerCase().contains(q) ||
                (t.teacherId ?? '').toLowerCase().contains(q);
          }).toList();

          return RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => admin.fetchTeachers(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
              itemCount: teachers.length + 1,
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search faculty',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      ),
                    ),
                  );
                }
                final t = teachers[idx - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.brand500,
                      child: Text(
                        t.name.isNotEmpty ? t.name[0] : 'T',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('${t.teacherId ?? 'ID'} · ${t.designation ?? 'Faculty'} · ${t.department ?? ''}\n${t.email}', maxLines: 2, overflow: TextOverflow.ellipsis),
                    isThreeLine: true,
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
