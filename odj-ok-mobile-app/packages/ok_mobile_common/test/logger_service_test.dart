import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

void main() {
  late LoggerService loggerService;

  group('Logger Service Local file manipulation', () {
    setUp(() {
      loggerService = LoggerService();
      final directory = Directory('${Directory.current.path}/Logs')
        ..createSync(recursive: true);
      for (final file in directory.listSync()) {
        if (file is File) {
          file.deleteSync();
        }
      }
    });

    test('saveLogsToFile() creates a correct file', () async {
      await loggerService.saveLogsToFile('Test Error');

      final path = await LoggerService.getDirectory();

      final logFile = File(
        '$path/Logs/${DatesHelper.formatDateTimeOneLineOnlyDate(DateTime.now())}_error_logs.txt',
      );
      expect(logFile.existsSync(), isTrue);
      expect(
        logFile.uri.pathSegments.last,
        '${DatesHelper.formatDateTimeOneLineOnlyDate(DateTime.now())}'
        '_error_logs.txt',
      );
    });

    test('saveLogsToFile() appends logs in a correct order', () async {
      await loggerService.saveLogsToFile('Test Error 1');
      await loggerService.saveLogsToFile('Test Error 2');

      final path = await LoggerService.getDirectory();

      final logFile = File(
        '$path/Logs/${DatesHelper.formatDateTimeOneLineOnlyDate(DateTime.now())}_error_logs.txt',
      );
      expect(logFile.existsSync(), isTrue);
      expect(
        logFile.readAsLinesSync(),
        containsAllInOrder(['Error: Test Error 2', 'Error: Test Error 1']),
      );
    });

    test('removeObsoleteLogs() deletes correct files', () async {
      final path = await LoggerService.getDirectory();

      for (var i = 1; i <= 14; i++) {
        final oldDate = DateTime.now().subtract(Duration(days: i));
        File(
          '$path/Logs/${DatesHelper.formatDateTimeOneLineOnlyDate(oldDate)}_error_logs.txt',
        ).createSync(recursive: true);
      }

      final directory = Directory('$path/Logs');
      var logFiles = directory.listSync();

      expect(logFiles.length, equals(14));

      await loggerService.removeObsoleteLogs();

      logFiles = directory.listSync()
        ..sort((a, b) {
          return a.path.compareTo(b.path);
        });

      expect(logFiles.length, equals(7));
      expect(
        logFiles.any(
          (file) =>
              file.uri.pathSegments.last ==
              '''${DatesHelper.formatDateTimeOneLineOnlyDate(DateTime.now().subtract(const Duration(days: 7)))}_error_logs.txt''',
        ),
        true,
      );
    });
  });
}
