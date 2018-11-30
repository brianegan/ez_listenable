import 'package:common/src/search/models/search_results.dart';

// The State classes are used to represent the different states the UI can exist
// in. It can only exist in one state at a time! It is essentially a state
// machine.
//
// The State Listenable will emit new States depending on the situation: The
// initial state, loading states, the list of results, and any errors that
// happen.
abstract class SearchState {}

class SearchLoading implements SearchState {
  const SearchLoading();
}

class SearchError implements SearchState {
  const SearchError();
}

class SearchNoTerm implements SearchState {
  const SearchNoTerm();
}

class SearchPopulated implements SearchState {
  final SearchResults result;

  SearchPopulated(this.result);
}

class SearchEmpty implements SearchState {
  const SearchEmpty();
}
