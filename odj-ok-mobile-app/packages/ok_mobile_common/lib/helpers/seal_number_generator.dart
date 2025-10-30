// Utility script
//
// From ./operator-main-system.monorepo/odj-ok-mobile-app
// $ dart packages/ok_mobile_common/lib/seal {number}
//
// If you need to input one seal number to an active text field use
// $ adb shell input text $(dart seal 1)
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:checkdigit/checkdigit.dart';
import 'package:collection/collection.dart';

void main(List<String> args) {
  if (args.length > 1 || int.tryParse(args.first) == null) {
    throw Exception('Provide a valid number of seals to generate');
  }

  final sealCount = int.parse(args.first);
  const sealPrefix = '02';
  const dammGenerator = Damm();
  final randomGenerator = Random();
  final sealNumbers = <String>[];

  for (var i = 0; i < sealCount; i++) {
    final random13 = randomGenerator
        .nextInt(pow(2, 32).toInt())
        .toString()
        .padLeft(12, '0');
    final checkDigit = dammGenerator.checkDigit('$sealPrefix$random13');
    sealNumbers.add('02$random13$checkDigit');
  }

  if (sealNumbers.length == 1) {
    stdout.write(sealNumbers.first);
    return;
  }

  sealNumbers.forEachIndexed(
    (index, number) => print('Numer ${index + 1}: $number'),
  );
}
