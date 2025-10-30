import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

void main() {
  group('DatesHelper', () {
    test('calculateDifference should return correct difference in days', () {
      final date = DateTime.now().subtract(const Duration(days: 5));
      final difference = DatesHelper.calculateDifference(date);
      expect(difference, -5);
    });

    test('formatDateTimeTwoLines should format date correctly', () {
      final dateTime = DateTime(2023, 10, 1, 14, 30);
      final formatted = DatesHelper.formatDateTimeTwoLines(dateTime);
      expect(formatted, '01.10.23\n14:30');
    });

    test('formatDateTimeOneLine should format date correctly', () {
      final dateTime = DateTime(2023, 10, 1, 14, 30);
      final formatted = DatesHelper.formatDateTimeOneLine(dateTime);
      expect(formatted, '01.10.23 14:30');
    });

    test('isTheSameDay should return true for the same day', () {
      final dayA = DateTime(2023, 10, 2);
      final dayB = DateTime(2023, 10, 2, 23, 59);
      final result = DatesHelper.isTheSameDay(dayA, dayB);
      expect(result, true);
    });

    test('isTheSameDay should return false for different days', () {
      final dayA = DateTime(2023, 10, 5);
      final dayB = DateTime(2023, 10, 2);
      final result = DatesHelper.isTheSameDay(dayA, dayB);
      expect(result, false);
    });
  });

  group('DateTimeUtilities extension', () {
    test("isToday should return true for today's date", () {
      final today = DateTime.now();
      expect(today.isToday, true);
    });

    test('isToday should return false for a different date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, false);
    });

    test('isNotToday should return true for a different date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isNotToday, true);
    });

    test("isNotToday should return false for today's date", () {
      final today = DateTime.now();
      expect(today.isNotToday, false);
    });
  });
}
