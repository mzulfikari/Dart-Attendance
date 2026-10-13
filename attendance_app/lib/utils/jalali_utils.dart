import 'package:shamsi_date/shamsi_date.dart';

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
    return input.replaceAllMapped(
      RegExp(r'\d'),
      (match) => _persianDigits[int.parse(match.group(0)!)],
    );
  }

  static String toPersianDigitsInt(int number) {
    return toPersianDigits(number.toString());
  }

  static Jalali toJalali(DateTime gregorian) {
    return Jalali.fromDateTime(gregorian);
  }

  static DateTime toGregorian(Jalali jalali) {
    return jalali.toDateTime();
  }

  static DateTime fromJalaliParts(int year, int month, int day) {
    return toGregorian(Jalali(year, month, day));
  }

  static String monthName(int month) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    return _persianMonths[month - 1];
  }

  static String formatDate(DateTime date, {bool withWeekDay = false}) {
    final jalali = toJalali(date);
    final monthName = _persianMonths[jalali.month - 1];
    final day = toPersianDigitsInt(jalali.day);
    final year = toPersianDigitsInt(jalali.year);
    var result = '$day $monthName $year';
    if (withWeekDay) {
      // DateTime.weekday: Monday=1 ... Sunday=7; Jalali week starts Saturday.
      final weekDay = _persianWeekDays[(date.weekday + 1) % 7];
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
      final normalized = input
          .trim()
          .replaceAll('۰', '0')
          .replaceAll('۱', '1')
          .replaceAll('۲', '2')
          .replaceAll('۳', '3')
          .replaceAll('۴', '4')
          .replaceAll('۵', '5')
          .replaceAll('۶', '6')
          .replaceAll('۷', '7')
          .replaceAll('۸', '8')
          .replaceAll('۹', '9')
          .replaceAll('٠', '0')
          .replaceAll('١', '1')
          .replaceAll('٢', '2')
          .replaceAll('٣', '3')
          .replaceAll('٤', '4')
          .replaceAll('٥', '5')
          .replaceAll('٦', '6')
          .replaceAll('٧', '7')
          .replaceAll('٨', '8')
          .replaceAll('٩', '9');
      final parts = normalized.split('/');
      if (parts.length != 3) return null;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return toGregorian(Jalali(year, month, day));
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
    return toGregorian(Jalali(jalali.year, jalali.month, 1));
  }

  static DateTime endOfMonth(DateTime date) {
    final jalali = toJalali(date);
    final nextMonth = jalali.month == 12 ? 1 : jalali.month + 1;
    final nextYear = jalali.month == 12 ? jalali.year + 1 : jalali.year;
    return toGregorian(Jalali(nextYear, nextMonth, 1))
        .subtract(const Duration(milliseconds: 1));
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final start = startOfMonth(date);
    final end = endOfMonth(date);
    final days = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  static int getDaysInJalaliMonth(int year, int month) {
    return Jalali(year, month, 1).monthLength;
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
