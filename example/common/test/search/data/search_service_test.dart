import 'package:common/common.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../utils.dart';

class MockClient extends Mock implements SearchClient {}

void main() {
  group('SearchService', () {
    test('should load from the cache', () async {
      final cache = SearchCache();
      final client = MockClient();
      final service = SearchService(cache: cache, client: client);
      final results = searchResults;

      cache.set('A', results);

      expect(await service.search('A'), results);
      verifyNever(client.search('A'));
    });

    test('falls back to the client if the results is not cached', () async {
      final cache = SearchCache();
      final client = MockClient();
      final service = SearchService(cache: cache, client: client);
      final results = searchResults;

      when(client.search(('A'))).thenAnswer((_) async => results);

      expect(await service.search('A'), results);
      verify(client.search('A'));
    });

    test('caches the results after fetching from the client', () async {
      final cache = SearchCache();
      final client = MockClient();
      final service = SearchService(cache: cache, client: client);
      final results = searchResults;

      when(client.search(('A'))).thenAnswer((_) async => results);

      expect(await service.search('A'), results);
      expect(cache.get('A'), results);
    });
  });
}
