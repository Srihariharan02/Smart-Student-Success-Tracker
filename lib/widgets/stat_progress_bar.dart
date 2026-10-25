import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatProgressBar extends StatelessWidget {
  final num percentage;
  final double height;
  final Color? color;

  const StatProgressBar({
    super.key,
    required this.percentage,
    this.height = 7.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkInk100 : AppColors.lightInk100;
    final fillColor = color ?? AppColors.scoreColor(percentage);
    final clampedPercent = (percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth * clampedPercent,
            height: height,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}
