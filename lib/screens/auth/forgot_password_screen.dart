import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _auth = AuthService();
  final _identifierCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _hint;
  bool _obscure = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_identifierCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Enter your registered email or Student ID');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _auth.requestPasswordOtp(_identifierCtrl.text.trim());
      setState(() {
        _step = 1;
        _hint = data['email_hint']?.toString();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.trim().length < 4) {
      setState(() => _error = 'Enter the 6-digit OTP sent to your email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.verifyPasswordOtp(_identifierCtrl.text.trim(), _otpCtrl.text.trim());
      setState(() => _step = 2);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final err = Validators.password(_passwordCtrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.resetPasswordWithOtp(
        identifier: _identifierCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please log in.')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pad = Responsive.horizontalPadding(context);

    String title;
    String subtitle;
    if (_step == 0) {
      title = 'Forgot password';
      subtitle = 'We will send a one-time password to your registered email.';
    } else if (_step == 1) {
      title = 'Enter OTP';
      subtitle = _hint == null
          ? 'Check your registered email for the 6-digit code.'
          : 'A code was sent to $_hint.';
    } else {
      title = 'Set new password';
      subtitle = 'Choose a password of at least 6 characters.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 20, pad, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger500, fontSize: 12)),
                  ),
                if (_step == 0) ...[
                  CustomTextField(
                    controller: _identifierCtrl,
                    label: 'Registered email or Student ID',
                    hintText: 'email@college.edu or STU...',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Send OTP',
                    icon: Icons.send_rounded,
                    isLoading: _loading,
                    onPressed: _sendOtp,
                  ),
                ] else if (_step == 1) ...[
                  CustomTextField(
                    controller: _otpCtrl,
                    label: 'One-time password',
                    hintText: '6-digit code',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Verify OTP',
                    icon: Icons.verified_outlined,
                    isLoading: _loading,
                    onPressed: _verifyOtp,
                  ),
                  TextButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ] else ...[
                  CustomTextField(
                    controller: _passwordCtrl,
                    label: 'New password',
                    obscureText: _obscure,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Update password',
                    icon: Icons.lock_reset_rounded,
                    isLoading: _loading,
                    onPressed: _resetPassword,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
