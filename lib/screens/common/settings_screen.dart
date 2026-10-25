import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePasswordModal(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change Password', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                CustomTextField(controller: currentCtrl, label: 'Current Password', obscureText: true),
                const SizedBox(height: 10),
                CustomTextField(controller: newCtrl, label: 'New Password', obscureText: true),
                const SizedBox(height: 18),
                CustomButton(
                  text: 'Update Password',
                  icon: Icons.lock_reset_rounded,
                  onPressed: () async {
                    if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) return;
                    try {
                      await AuthService().changePassword(currentCtrl.text, newCtrl.text);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password updated successfully!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger500),
                        );
                      }
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

  void _showServerUrlDialog(BuildContext context) {
    final urlCtrl = TextEditingController(text: ApiConstants.activeBaseUrl);
    bool isTesting = false;
    String? statusMsg;
    bool? isSuccess;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void pickPreset(String url) {
            setDialogState(() {
              urlCtrl.text = url;
              statusMsg = null;
              isSuccess = null;
            });
          }

          Future<void> testAndSave({bool saveAnyway = false}) async {
            final raw = urlCtrl.text.trim();
            final sanitized = ApiConstants.sanitizeBaseUrl(raw);
            urlCtrl.text = sanitized;

            setDialogState(() {
              isTesting = true;
              statusMsg = 'Pinging $sanitized...';
              isSuccess = null;
            });

            final ok = await ApiClient().testConnection(sanitized);

            setDialogState(() {
              isTesting = false;
              isSuccess = ok;
              statusMsg = ok
                  ? 'Connected successfully to Flask backend!'
                  : 'Server not reachable at $sanitized. Ensure Flask is running on port 5000 and phone is on the same Wi-Fi.';
            });

            if (ok || saveAnyway) {
              ApiConstants.customBaseUrl = sanitized;
              await LocalStorage.saveApiBaseUrl(sanitized);
              await Future.delayed(const Duration(milliseconds: 300));
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? AppColors.success500 : AppColors.warn500,
                    content: Text('Server saved: ${ApiConstants.activeBaseUrl}'),
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.dns_rounded, color: AppColors.brand500, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Server Endpoint', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Presets (Tap to select):',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightInk500),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.wifi_rounded, size: 14),
                        label: const Text('Wi-Fi PC (192.168.0.106)', style: TextStyle(fontSize: 11)),
                        onPressed: () => pickPreset('http://192.168.0.106:5000/api'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.usb_rounded, size: 14),
                        label: const Text('USB Cable (127.0.0.1)', style: TextStyle(fontSize: 11)),
                        onPressed: () => pickPreset('http://127.0.0.1:5000/api'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.devices_rounded, size: 14),
                        label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                        onPressed: () => pickPreset('http://10.0.2.2:5000/api'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: urlCtrl,
                    label: 'API Base URL',
                    hintText: 'http://192.168.0.106:5000/api',
                  ),
                  if (statusMsg != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSuccess == true
                            ? AppColors.success500.withValues(alpha: 0.1)
                            : (isSuccess == false ? AppColors.danger500.withValues(alpha: 0.1) : AppColors.brand500.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          if (isTesting)
                            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            Icon(
                              isSuccess == true ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                              size: 16,
                              color: isSuccess == true ? AppColors.success500 : AppColors.danger500,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusMsg!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSuccess == true
                                    ? AppColors.success500
                                    : (isSuccess == false ? AppColors.danger500 : AppColors.brand500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isTesting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              if (isSuccess == false)
                TextButton(
                  onPressed: isTesting ? null : () => testAndSave(saveAnyway: true),
                  child: const Text('Save Anyway', style: TextStyle(color: AppColors.lightInk500)),
                ),
              ElevatedButton.icon(
                icon: isTesting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.network_check_rounded, size: 16),
                label: Text(isTesting ? 'Testing...' : 'Test & Save'),
                onPressed: isTesting ? null : () => testAndSave(),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPad = Responsive.horizontalPadding(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.brand500,
                      child: Text(
                        auth.user?.initials ?? 'U',
                        style: GoogleFonts.lexend(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user?.name ?? 'User',
                            style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${auth.userRole.toUpperCase()} · ${auth.user?.email ?? ''}',
                            style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                          ),
                          if (auth.user?.studentId != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${auth.user!.studentId}',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brand500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('App Preferences', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Dark Theme', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text('Enable dark canvas for low light environments', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500)),
                    value: theme.isDarkMode,
                    activeThumbColor: AppColors.brand500,
                    onChanged: (val) => theme.toggleTheme(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Server Connection', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(ApiConstants.activeBaseUrl, style: const TextStyle(fontSize: 11, color: AppColors.brand500)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showServerUrlDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Change Password', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showChangePasswordModal(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('About S3T Mobile', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Student Success Tracker (SSST)', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Version 1.0.0 • Production Build', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500)),
                    const SizedBox(height: 8),
                    Text(
                      'AI-Powered academic performance, early warning intervention, and personal study scheduling for higher education institutions.',
                      style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: isDark ? AppColors.darkInk700 : AppColors.lightInk700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Log Out of S3T',
              icon: Icons.logout_rounded,
              variant: ButtonVariant.danger,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
