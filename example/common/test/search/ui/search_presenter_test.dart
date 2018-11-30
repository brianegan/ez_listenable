import 'package:common/common.dart';
import 'package:ez_listenable_test/ez_listenable_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('SearchPresenter', () {
    test('starts with an initial no term state', () {
      final service = MockSearchService();
      final presenter = SearchPresenter(
        service: service,
        debounceDuration: Duration.zero,
      );

      expect(presenter, noTerm);
    });

    test('emits loading then a result state when service call succeeds', () {
      final service = MockSearchService();
      final presenter = SearchPresenter(
        service: service,
        debounceDuration: Duration.zero,
      );

      when(service.search('T'))
          .thenAnswer((_) async => SearchResults(items: [Repo()]));

      presenter.onTermChange('T');

      expect(
        presenter,
        notifiesInOrder([loading, populated]),
      );
    });

    test('emits a no term state when user provides an empty search term', () {
      final service = MockSearchService();
      final presenter = SearchPresenter(
        service: service,
        debounceDuration: Duration.zero,
      );

      presenter.onTermChange('');

      expect(
        presenter,
        notifiesInOrder([noTerm]),
      );
    });

    test('emits an empty state when no results are returned', () {
      final service = MockSearchService();
      final presenter = SearchPresenter(
        service: service,
        debounceDuration: Duration.zero,
      );

      when(service.search('T'))
          .thenAnswer((_) async => SearchResults(items: []));

      presenter.onTermChange('T');

      expect(
        presenter,
        notifiesInOrder([loading, empty]),
      );
    });

    test('throws an error when the backend errors', () {
      final service = MockSearchService();
      final presenter = SearchPresenter(
        service: service,
        debounceDuration: Duration.zero,
      );

      when(service.search('T')).thenThrow(Exception());

      presenter.onTermChange('T');

      expect(
        presenter,
        notifiesInOrder([loading, error]),
      );
    });
  });
}

class MockSearchService extends Mock implements SearchService {}

Matcher state(dynamic matcher) {
  return predicate<SearchPresenter>(
    (listenable) {
      if (matcher is Matcher) {
        return matcher.matches(listenable.state, <dynamic, dynamic>{});
      } else {
        return listenable.state == matcher;
      }
    },
    'State was not $matcher',
  );
}

final noTerm = state(const SearchNoTerm());

final loading = state(const SearchLoading());

final empty = state(const SearchEmpty());

final populated = state(TypeMatcher<SearchPopulated>());

final error = state(const SearchError());
