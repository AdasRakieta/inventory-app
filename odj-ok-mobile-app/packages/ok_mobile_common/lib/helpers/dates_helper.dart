part of '../ok_mobile_common.dart';

class DatesHelper {
  static int calculateDifference(DateTime date) {
    final now = DateTime.now();
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }

  static String formatToIfModifiedSince(DateTime dateTime) {
    return '${DateFormat('EEE, dd MMM yyyy hh:mm:ss', 'en').format(dateTime)} '
        'GMT';
  }

  static String formatDateTimeTwoLines(DateTime dateTime) {
    return DateFormat('dd.MM.yy\nHH:mm').format(dateTime);
  }

  static String formatDateTimeOneLine(DateTime dateTime) {
    return DateFormat('dd.MM.yy HH:mm').format(dateTime);
  }

  static String formatDateTimeOneLineOnlyDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  static bool isTheSameDay(DateTime? dayA, DateTime? dayB) {
    return isSameDay(dayA, dayB);
  }

  static String asUTC(String? dateTime) {
    if (dateTime == null) {
      return '1970-01-01 00:00:00.000Z';
    }
    return dateTime.endsWith('Z') ? dateTime : '$dateTime Z';
  }
}

extension DateTimeUtilities on DateTime {
  bool get isToday {
    return DatesHelper.calculateDifference(this) == 0;
  }

  bool get isNotToday {
    return DatesHelper.calculateDifference(this) != 0;
  }
}
