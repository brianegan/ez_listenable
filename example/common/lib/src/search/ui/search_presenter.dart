import 'dart:async';

import 'package:async/async.dart';
import 'package:common/src/search/data/search_service.dart';
import 'package:common/src/search/models/search_results.dart';
import 'package:common/src/search/ui/search_state.dart';
import 'package:ez_listenable/ez_listenable.dart';

/// For a search screen, the presenter manages a simple State machine. It will
/// transition to a No Term, Loading, Empty, Populated, or Error state depending
/// on the situation.
///
/// The UI layer can synchronously read the current state from the presenter,
/// and listen to the presenter to be notified when the state changes.
///
/// The UI layer can send new search terms to the presenter via the
/// `onTermChanged` method. This can be hooked up to a TextField in Flutter or
/// an html onChanged event.
class SearchPresenter extends EzNotifier {
  final Duration _debounceDuration;
  final SearchService _service;
  Timer _debounceTimer;
  CancelableOperation<SearchResults> _operation;
  SearchState _state;

  SearchPresenter({
    SearchService service,
    SearchState state,
    Duration debounceDuration,
  })  : _state = state ?? const SearchNoTerm(),
        _debounceDuration = debounceDuration ?? Duration(milliseconds: 500),
        _service = service ?? SearchService();

  /// Sync access to the current state
  SearchState get state => _state;

  /// A function that should be run each time the search term changes.
  ///
  /// It is responsible for starting a new search after waiting a short period
  /// of time. This ensures we do not "over-fetch" too many search results.
  void onTermChange(String term) {
    // Cancel any of our pending operations! This will do two things:
    //   1. The first line will cancel the last request that haven't started
    //   2. The second line cancels any previous requests that have started but
    //      have not completed
    _debounceTimer?.cancel();
    _operation?.cancel();

    // Then, start the search process again! This will wait for 500ms before
    // starting another search.
    _debounceTimer = Timer(
      _debounceDuration,
      () async {
        if (term.isEmpty) {
          _setState(const SearchNoTerm());
        } else {
          _setState(const SearchLoading());

          try {
            // We wrap our search call in a cancellable operation!
            _operation = CancelableOperation.fromFuture(_service.search(term));
            final results = await _operation.value;

            if (results.isEmpty) {
              _setState(const SearchEmpty());
            } else {
              _setState(SearchPopulated(results));
            }
          } catch (e) {
            _setState(const SearchError());
          }
        }
      },
    );
  }

  void _setState(SearchState state) {
    _state = state;
    notifyListeners();
  }
}
