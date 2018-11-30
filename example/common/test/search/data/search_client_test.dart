import 'dart:io';

import 'package:common/common.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  String fixture(String name) =>
      File('test/data/fixtures/$name.json').readAsStringSync();

  group('GithubClient', () {
    test('should fetch and parse results from the api', () async {
      final client = SearchClient(
        client: MockClient(
          (_) async => Response(fixture('search_results'), 200),
        ),
      );
      final result = await client.search('yo');
      final item = result.items.first;

      expect(result.items.length, 3);
      expect(item, TypeMatcher<Repo>());
      expect(item.fullName, 'yeoman/yo');
      expect(item.htmlUrl, 'https://github.com/yeoman/yo');
      expect(item.owner.login, 'yeoman');
      expect(
        item.owner.avatarUrl,
        'https://avatars0.githubusercontent.com/u/1714870?v=4',
      );
    });

    test('should throw an error on bad status code', () {
      final client = SearchClient(
        client: MockClient(
          (_) async => Response(fixture('search_error'), 403),
        ),
      );

      expect(
        client.search('yo'),
        throwsA(TypeMatcher<SearchResultsError>()),
      );
    });
  });
}
