import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
  }

  static String formatDayHeader(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    if (normalizedDate == today) {
      return 'Hôm nay';
    }
    if (normalizedDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    }

    return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatWeekdayShort(DateTime date) {
    return DateFormat('E', 'vi_VN').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy', 'vi_VN').format(date);
  }

  static String formatShortMonth(DateTime date) {
    return DateFormat('MM', 'vi_VN').format(date);
  }
}
