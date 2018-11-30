@TestOn('browser')
import 'package:angular/angular.dart';
import 'package:ez_listenable/ez_listenable.dart';
import 'package:ez_listenable_angular/ez_listenable_angular.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('ListenPipe', () {
    test('should return the listenable', () {
      final ez = EzValue<String>('A');
      final ref = MockChangeDetectorRef();
      final pipe = ListenPipe(ref);

      expect(pipe.transform(ez), ez);
    });

    test('throws if the provided value is not a listenable', () {
      final ref = MockChangeDetectorRef();
      final pipe = ListenPipe(ref);

      expect(
        () => pipe.transform('Oh no'),
        throwsA(TypeMatcher<AssertionError>()),
      );
    });

    test('should listen to listenable and mark for check upon value change',
        () {
      final ez = EzValue<String>('A');
      final ref = MockChangeDetectorRef();
      final pipe = ListenPipe(ref);

      pipe.transform(ez);

      ez.value = 'B';

      verify(ref.markForCheck()).called(1);
    });

    test('should unsubscribe from the old listenable and listen to the new one',
        () {
      final original = EzValue<String>('A');
      final update = EzValue<String>('B');
      final ref = MockChangeDetectorRef();
      final pipe = ListenPipe(ref);

      pipe.transform(original);
      pipe.transform(update);

      original.value = 'B';

      verifyNever(ref.markForCheck());

      update.value = 'C';

      verify(ref.markForCheck());
    });

    test('should unsubscribe on dispose', () {
      final ez = EzValue<String>('A');
      final ref = MockChangeDetectorRef();
      final pipe = ListenPipe(ref);

      pipe.transform(ez);
      pipe.ngOnDestroy();

      ez.value = 'B';

      verifyNever(ref.markForCheck());
    });
  });
}

class MockChangeDetectorRef extends Mock implements ChangeDetectorRef {}
