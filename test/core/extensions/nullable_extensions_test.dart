import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/extensions/nullable_extensions.dart';

void main() {
  test('string nullable helpers detect empty and blank values', () {
    String? value;

    expect(value.isNullOrEmpty(), isTrue);
    expect(value.isNullOrBlank(), isTrue);
    expect(''.isNullOrEmpty(), isTrue);
    expect('   '.isNullOrBlank(), isTrue);
    expect('pernit'.isNullOrEmpty(), isFalse);
  });

  test('collection nullable helpers detect null or empty values', () {
    List<int>? numbers;
    Map<String, int>? values;

    expect(numbers.isNullOrEmpty(), isTrue);
    expect(values.isNullOrEmpty(), isTrue);
    expect(<int>[1].isNullOrEmpty(), isFalse);
    expect(<String, int>{'id': 1}.isNullOrEmpty(), isFalse);
  });
}
