import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatTransactionDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (isSameDay(dateTime, now)) {
      return 'Today, $timeStr';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(dateTime, yesterday)) {
      return 'Yesterday, $timeStr';
    }

    if (dateTime.year == now.year) {
      return '${DateFormat('MMM d').format(dateTime)}, $timeStr';
    }

    return '${DateFormat('MMM d, yyyy').format(dateTime)}, $timeStr';
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime);
  }

  static String formatShortMonthYear(DateTime dateTime) {
    return DateFormat('MMM yyyy').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatDayOfWeek(DateTime dateTime) {
    return DateFormat('EEE').format(dateTime);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
