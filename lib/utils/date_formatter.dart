import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy', 'vi_VN').format(date);
  }

  static String formatShortMonth(DateTime date) {
    return DateFormat('MM', 'vi_VN').format(date);
  }
}
