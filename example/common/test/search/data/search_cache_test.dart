import 'package:common/common.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('SearchCache', () {
    test('should save results based on the term', () async {
      final cache = SearchCache();
      final results = searchResults;

      cache.set('A', results);

      expect(cache.get('A'), results);
    });

    test('should remove values', () async {
      final cache = SearchCache();

      cache.set('A', searchResults);
      cache.remove('A');

      expect(cache.get('A'), isNull);
    });

    test('should determine if a term is cached', () async {
      final cache = SearchCache();
      final results = searchResults;

      expect(cache.contains('A'), isFalse);

      cache.set('A', results);

      expect(cache.contains('A'), isTrue);
    });
  });
}
