import 'package:ez_listenable/ez_listenable.dart';
import 'package:test/test.dart';

void main() {
  group('EzNotifier', () {
    test('should register a callback that is invoked on every change', () {
      final ez = new EzValue('A');
      final counter = new CallCounter();

      ez.addListener(counter);
      ez.value = 'B';
      ez.value = 'C';

      expect(counter.count, 2);
      expect(ez.value, 'C');
      expect(ez.version, 2);
    });

    test('should register a callback that is invoked only one time', () {
      final ez = new EzValue('A');
      final counter = new CallCounter();

      ez.once(counter);
      ez.value = 'B';
      ez.value = 'C';

      expect(counter.count, 1);
      expect(ez.value, 'C');
      expect(ez.version, 2);
    });

    test('should remove listeners', () {
      final ez = new EzValue('A');
      final counter = new CallCounter();

      ez.addListener(counter);
      ez.removeListener(counter);
      ez.value = 'B';

      expect(counter.count, 0);
      expect(ez.value, 'B');
    });

    test('should be unusable after being disposed', () {
      final ez = new EzValue('A');
      final counter = new CallCounter();

      ez.addListener(counter);
      ez.dispose();

      expect(ez.value, 'A');
      expect(() => ez.value = 'B', throwsException);
    });
  });

  group('EzValue', () {
    test('should accept an initial value', () {
      expect(EzValue('A').value, 'A');
    });

    test('should run a callback when the value changes', () {
      final ez = EzValue('A');
      final counter = CallCounter();

      ez.addListener(counter);

      ez.value = 'B';

      expect(ez.value, 'B');
      expect(counter.count, 1);
    });

    test('should not run a callback that has been removed', () {
      final ez = EzValue('A');
      final counter = CallCounter();

      ez.addListener(counter);
      ez.removeListener(counter);

      ez.value = 'B';

      expect(ez.value, 'B');
      expect(counter.count, 0);
    });
  });

  group('EzComputation', () {
    test('initial value should be computed', () {
      final counter = EzValue<int>(0);
      final addOne = EzComputedValue<int>(counter, () => counter.value + 1);

      expect(addOne.value, 1);
    });

    test('value should be recomputed when the source invokes listeners', () {
      final counter = EzValue<int>(0);
      final addOne = EzComputedValue<int>(counter, () => counter.value + 1);

      counter.value = 1;

      expect(addOne.value, 2);
    });

    test('should notify listeners when they are registered', () {
      final counter = EzValue<int>(0);
      final addOne = EzComputedValue<int>(counter, () => counter.value + 1);
      var callCount = 0;
      void listener() => callCount++;

      addOne.addListener(listener);

      counter.value = 1;
      counter.value = 2;

      expect(callCount, 2);

      addOne.removeListener(listener);

      counter.value = 3;

      expect(callCount, 2);
    });

    test('should recomputed based on multiple listenables', () {
      final counterA = EzValue<int>(0);
      final counterB = EzValue<int>(0);
      final sum = EzComputedValue<int>.merge(
        [counterA, counterB],
        () => counterA.value + counterB.value,
      );

      expect(sum.value, 0);

      counterA.value = 1;

      expect(sum.value, 1);

      counterB.value = 2;

      expect(sum.value, 3);
    });

    test('should stop listening upon being disposed', () {
      final counterA = EzValue<int>(0);
      final addOne = EzComputedValue<int>(counterA, () => counterA.value + 1);

      counterA.value = 1;

      expect(addOne.value, 2);

      addOne.dispose();

      counterA.value = 5;

      expect(addOne.value, 2);
    });
  });
}

class CallCounter {
  int count = 0;

  void call() {
    count++;
  }
}
