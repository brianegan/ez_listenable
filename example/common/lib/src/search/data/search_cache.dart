import 'package:common/src/search/models/search_results.dart';

/// A simple in-memory cached. At the moment, it's backed up by a Map, but it
/// could be backed up by a more advanced data structure if need be.
class SearchCache {
  final _cache = <String, SearchResults>{};

  SearchResults get(String term) => _cache[term];

  void set(String term, SearchResults result) => _cache[term] = result;

  bool contains(String term) => _cache.containsKey(term);

  void remove(String term) => _cache.remove(term);
}
