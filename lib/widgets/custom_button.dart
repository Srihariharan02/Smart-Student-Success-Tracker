import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

enum ButtonVariant { primary, outline, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getBackgroundColor() {
      switch (variant) {
        case ButtonVariant.primary:
          return AppColors.brand500;
        case ButtonVariant.danger:
          return AppColors.danger500;
        case ButtonVariant.outline:
          return Colors.transparent;
      }
    }

    Color getForegroundColor() {
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.danger:
          return Colors.white;
        case ButtonVariant.outline:
          return isDark ? AppColors.darkInk900 : AppColors.lightInk700;
      }
    }

    BorderSide getBorderSide() {
      if (variant == ButtonVariant.outline) {
        return BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.2);
      }
      return BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: getForegroundColor(),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: getForegroundColor()),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: getForegroundColor(),
          ),
        ),
      ],
    );

    final btnStyle = ElevatedButton.styleFrom(
      backgroundColor: getBackgroundColor(),
      foregroundColor: getForegroundColor(),
      elevation: 0,
      side: getBorderSide(),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        style: btnStyle,
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );
  }
}
