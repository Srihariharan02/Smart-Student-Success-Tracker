import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      if (date is DateTime) {
        return DateFormat('d MMM yyyy').format(date);
      }
      final parsed = DateTime.parse(date.toString());
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  static String formatPercent(num? value) {
    if (value == null) return '0%';
    if (value is int || value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
