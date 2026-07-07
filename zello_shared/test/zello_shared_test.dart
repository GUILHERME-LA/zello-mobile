import 'package:flutter_test/flutter_test.dart';
import 'package:zello_shared/zello_shared.dart';

void main() {
  test('Formatters.getInitials works correctly', () {
    expect(Formatters.getInitials('João Silva'), 'JS');
    expect(Formatters.getInitials('Ana'), 'A');
    expect(Formatters.getInitials(''), '?');
  });
}
