import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/storage/local_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _identifierController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      final role = authProvider.userRole.toLowerCase();
      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRoutes.teacherMain);
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.studentMain);
      }
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit SSST'),
        content: const Text('Close Smart Student Success Tracker?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Exit')),
        ],
      ),
    );
    return shouldExit == true;
  }

  void _showServerConfigDialog() {
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
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              if (isSuccess == false)
                TextButton(
                  onPressed: () => testAndSave(saveAnyway: true),
                  child: const Text('Save Anyway', style: TextStyle(color: AppColors.warn500)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand500, foregroundColor: Colors.white),
                onPressed: isTesting ? null : () => testAndSave(saveAnyway: false),
                child: isTesting ? const Text('Testing...') : const Text('Test & Save'),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _onWillPop();
        if (exit) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.dns_outlined, size: 22),
              tooltip: 'Configure Backend URL',
              onPressed: _showServerConfigDialog,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 12.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand500.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppStrings.appShortName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkInk700 : AppColors.lightInk700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.signInSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (auth.errorMessage == null) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger500.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.danger500.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.danger500, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    auth.errorMessage!,
                                    style: GoogleFonts.inter(
                                      color: AppColors.danger500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: _identifierController,
                                label: AppStrings.identifierLabel,
                                hintText: AppStrings.identifierHint,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                                validator: (val) => Validators.requiredField(val, message: 'Please enter your ID or Email'),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _passwordController,
                                label: AppStrings.passwordLabel,
                                hintText: AppStrings.passwordHint,
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: Validators.password,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: AppColors.brand500,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            AppStrings.rememberMe,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: isDark ? AppColors.darkInk700 : AppColors.lightInk700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                                    child: Text(
                                      AppStrings.forgotPassword,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brand500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return CustomButton(
                                    text: AppStrings.loginButton,
                                    icon: Icons.login_rounded,
                                    isLoading: auth.status == AuthStatus.authenticating,
                                    onPressed: _attemptLogin,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Accounts are created by the administrator. Students log in with Student ID. Teachers and admins log in with registered email.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.4,
                          color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
