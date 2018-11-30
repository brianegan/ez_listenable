import 'package:common/common.dart';
import 'package:ez_listenable_flutter/ez_listenable_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_test_utils/image_test_utils.dart';
import 'package:mobile/search_empty_view.dart';
import 'package:mobile/search_error_view.dart';
import 'package:mobile/search_intro_view.dart';
import 'package:mobile/search_loading_view.dart';
import 'package:mobile/search_result_view.dart';
import 'package:mobile/search_screen.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Search Screen', () {
    final findIntro = find.byType(SearchIntroView);
    final findLoading = find.byType(SearchLoadingView);
    final findEmpty = find.byType(SearchEmptyView);
    final findError = find.byType(SearchErrorView);
    final findPopulated = find.byType(SearchResultView);

    testWidgets('initially displays an intro screen', (tester) async {
      final presenter = SearchPresenter();
      final screen = EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      );

      await tester.pumpWidget(MaterialApp(home: screen));

      expect(findIntro, findsOneWidget);
    });

    testWidgets('displays a loading screen', (tester) async {
      final presenter = SearchPresenter(state: SearchLoading());
      final screen = EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      );

      await tester.pumpWidget(MaterialApp(home: screen));

      expect(findLoading, findsOneWidget);
    });

    testWidgets('transitions from one state to another', (tester) async {
      final presenter = MockPresenter()..state = SearchNoTerm();
      final screen = EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      );

      await tester.pumpWidget(MaterialApp(home: screen));

      expect(findIntro, findsOneWidget);

      presenter.state = SearchEmpty();

      await tester.pumpAndSettle();

      expect(findEmpty, findsOneWidget);
    });

    testWidgets('displays an empty screen', (tester) async {
      final presenter = SearchPresenter(state: SearchEmpty());
      final screen = EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      );

      await tester.pumpWidget(MaterialApp(home: screen));

      expect(findEmpty, findsOneWidget);
    });

    testWidgets('displays an error screen', (tester) async {
      final presenter = SearchPresenter(state: SearchError());
      final screen = EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      );

      await tester.pumpWidget(MaterialApp(home: screen));

      expect(findError, findsOneWidget);
    });

    testWidgets('displays a list of results', (tester) async {
      provideMockedNetworkImages(() async {
        final presenter = SearchPresenter(
          state: SearchPopulated(SearchResults(items: [
            Repo(
              fullName: '',
              url: '',
              owner: Owner(avatarUrl: ''),
            )
          ])),
        );
        final screen = EzProvider<SearchPresenter>(
          listenable: presenter,
          child: SearchScreen(),
        );

        await tester.pumpWidget(MaterialApp(home: screen));

        expect(findPopulated, findsOneWidget);
      });
    });

    testWidgets('sends the latest term to the presenter', (tester) async {
      final presenter = MockitoPresenter();
      final screen = EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      );

      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.enterText(find.byType(TextField), 'A');

      verify(presenter.onTermChange('A'));
    });
  });
}

class MockitoPresenter extends Mock implements SearchPresenter {}

class MockPresenter extends SearchPresenter {
  SearchState _state;

  SearchState get state => _state;

  set state(SearchState state) {
    _state = state;
    notifyListeners();
  }
}
