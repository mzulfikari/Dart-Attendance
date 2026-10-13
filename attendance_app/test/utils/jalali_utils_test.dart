import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/utils/jalali_utils.dart';

void main() {
  group('JalaliUtils', () {
    test('converts Gregorian dates to and from Jalali dates', () {
      final gregorian = DateTime(2024, 3, 20);
      final jalali = JalaliUtils.toJalali(gregorian);

      expect(jalali.year, 1403);
      expect(jalali.month, 1);
      expect(jalali.day, 1);
      expect(
        JalaliUtils.toGregorian(jalali),
        DateTime(2024, 3, 20),
      );
    });

    test('parses Persian digits in Jalali dates', () {
      expect(
        JalaliUtils.parseJalaliString('۱۴۰۳/۰۱/۰۱'),
        DateTime(2024, 3, 20),
      );
    });

    test('returns null for malformed or invalid Jalali dates', () {
      expect(JalaliUtils.parseJalaliString('1403-01-01'), isNull);
      expect(JalaliUtils.parseJalaliString('1402/12/30'), isNull);
    });

    test('returns the correct Jalali month lengths', () {
      expect(JalaliUtils.getDaysInJalaliMonth(1403, 12), 30);
      expect(JalaliUtils.getDaysInJalaliMonth(1402, 12), 29);
    });

    test('calculates the complete Jalali month range', () {
      final sampleDate = DateTime(2024, 3, 20);

      expect(JalaliUtils.startOfMonth(sampleDate), DateTime(2024, 3, 20));
      expect(
        JalaliUtils.endOfMonth(sampleDate),
        DateTime(2024, 4, 19, 23, 59, 59, 999),
      );
      expect(JalaliUtils.getDaysInMonth(sampleDate), hasLength(31));
    });

    test('formats dates with Persian digits and month names', () {
      expect(JalaliUtils.formatShortDate(DateTime(2024, 3, 20)), '۱۴۰۳/۰۱/۰۱');
      expect(JalaliUtils.monthName(1), 'فروردین');
    });
  });
}
