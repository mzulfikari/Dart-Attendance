import 'package:jalaali_date/jalaali_date.dart';
import 'package:intl/intl.dart';

class JalaliUtils {
  static const List<String> _persianMonths = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> _persianWeekDays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  static const List<String> _persianDigits = [
    '۰',
    '۱',
    '۲',
    '۳',
    '۴',
    '۵',
    '۶',
    '۷',
    '۸',
    '۹',
  ];

  static String toPersianDigits(String input) {
    return input.replaceAllMapped(RegExp(r'\d'), (match) => _persianDigits[int.parse(match.group(0)!)]);
  }

  static String toPersianDigitsInt(int number) {
    return toPersianDigits(number.toString());
  }

  static JalaliDateTime toJalali(DateTime gregorian) {
    return JalaliDateTime.fromDateTime(gregorian);
  }

  static DateTime toGregorian(JalaliDateTime jalali) {
    return jalali.toDateTime();
  }

  static String formatDate(DateTime date, {bool withWeekDay = false}) {
    final jalali = toJalali(date);
    final monthName = _persianMonths[jalali.month - 1];
    final day = toPersianDigitsInt(jalali.day);
    final year = toPersianDigitsInt(jalali.year);
    String result = '$day $monthName $year';
    if (withWeekDay) {
      final weekDay = _persianWeekDays[date.weekday % 7];
      result = '$weekDay، $result';
    }
    return result;
  }

  static String formatShortDate(DateTime date) {
    final jalali = toJalali(date);
    final month = toPersianDigitsInt(jalali.month).padLeft(2, '۰');
    final day = toPersianDigitsInt(jalali.day).padLeft(2, '۰');
    final year = toPersianDigitsInt(jalali.year);
    return '$year/$month/$day';
  }

  static String formatTime(DateTime time) {
    final hour = toPersianDigitsInt(time.hour).padLeft(2, '۰');
    final minute = toPersianDigitsInt(time.minute).padLeft(2, '۰');
    return '$hour:$minute';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} - ${formatTime(dateTime)}';
  }

  static DateTime? parseJalaliString(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return toGregorian(JalaliDateTime(year, month, day));
    } catch (_) {
      return null;
    }
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    final jalali = toJalali(date);
    return toGregorian(JalaliDateTime(jalali.year, jalali.month, 1));
  }

  static DateTime endOfMonth(DateTime date) {
    final jalali = toJalali(date);
    final nextMonth = jalali.month == 12 ? 1 : jalali.month + 1;
    final nextYear = jalali.month == 12 ? jalali.year + 1 : jalali.year;
    return toGregorian(JalaliDateTime(nextYear, nextMonth, 1)).subtract(const Duration(days: 1));
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final start = startOfMonth(date);
    final end = endOfMonth(date);
    final days = <DateTime>[];
    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  static int getDaysInJalaliMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return JalaliDateTime.isLeapYear(year) ? 30 : 29;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final target = startOfDay(date);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'امروز';
    if (diff == 1) return 'فردا';
    if (diff == -1) return 'دیروز';
    if (diff > 1 && diff < 7) return '${toPersianDigitsInt(diff)} روز دیگر';
    if (diff < -1 && diff > -7) return '${toPersianDigitsInt(-diff)} روز پیش';
    return formatDate(date);
  }
}