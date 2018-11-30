import 'dart:async';

import 'package:ez_listenable/ez_listenable.dart';
import 'package:ez_listenable_test/ez_listenable_test.dart';
import 'package:test/test.dart';

void main() {
  group('Ez Test Utils', () {
    test('can verify first value that was notified', () {
      final ez = EzValue<int>(0);

      scheduleMicrotask(() {
        ez.value = 1;
      });

      expect(ez, notifies(value(1)));
    });

    test('can verify values in order', () {
      final ez = EzValue<int>(0);

      scheduleMicrotask(() {
        ez.value = 1;
        ez.value = 2;
        ez.value = 3;
      });

      expect(ez, notifiesInOrder(<Matcher>[value(1), value(2), value(3)]));
    });

    test('can verify a value was emitted at some point', () {
      final ez = EzValue<int>(0);

      scheduleMicrotask(() {
        ez.value = 1;
        ez.value = 2;
        ez.value = 3;
      });

      expect(ez, notifiesThrough(value(3)));
    });
  });
}
