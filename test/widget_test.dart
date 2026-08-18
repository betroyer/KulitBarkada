import 'package:flutter_test/flutter_test.dart';

import 'package:barkada_plan/utils/formatters.dart';
import 'package:barkada_plan/utils/password.dart';
import 'package:barkada_plan/data/repositories.dart';

void main() {
  test('formats whole peso amounts', () {
    expect(formatPeso(5000), '₱5,000');
    expect(formatPeso(1200.5), '₱1,200.50');
  });

  test('hashes and verifies passwords', () {
    final salt = PasswordHasher.randomSalt();
    final hash = PasswordHasher.hash('secret', salt);
    expect(PasswordHasher.verify('secret', salt, hash), isTrue);
    expect(PasswordHasher.verify('nope', salt, hash), isFalse);
  });

  test('equal split assigns the remainder to the last member', () {
    final amounts = equalAmounts(2500, 5);
    expect(amounts.length, 5);
    expect(amounts.reduce((a, b) => a + b), 2500);
  });
}
