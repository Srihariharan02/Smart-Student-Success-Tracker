import 'package:flutter/material.dart';

/// Helper utilities for handling responsive layouts across different phone screen sizes
class Responsive {
  Responsive._();

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isMediumPhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 420;
  }

  static bool isLargePhone(BuildContext context) =>
      MediaQuery.of(context).size.width >= 420;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    return 24.0;
  }

  /// Returns grid crossAxisCount based on screen width
  static int gridCount(BuildContext context, {int min = 2, int max = 4}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return min;
    return max;
  }
}
