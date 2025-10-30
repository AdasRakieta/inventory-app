import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

void main() {
  test('Strings Helper capitalization', () {
    const text = 'hello';
    const textUpper = 'Hello';
    expect(textUpper.capitalize(), 'Hello');
    expect(text.capitalize(), 'Hello');
  });
}
