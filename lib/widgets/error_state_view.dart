import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'custom_button.dart';

class ErrorStateView extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    this.title = 'Failed to load data',
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.danger500.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 28, color: AppColors.danger500),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkInk500 : AppColors.lightInk500,
                    ),
                  ),
                ],
                if (onRetry != null) ...[
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Retry',
                    icon: Icons.refresh_rounded,
                    fullWidth: false,
                    onPressed: onRetry,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
