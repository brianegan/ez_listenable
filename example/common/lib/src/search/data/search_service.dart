import 'dart:async';

import 'package:common/src/search/data/search_cache.dart';
import 'package:common/src/search/data/search_client.dart';
import 'package:common/src/search/models/search_results.dart';

/// The SearchService is responsible for coordinating different data sources.
/// Currently, it coordinates an in-memory cache and falls back to a web service
/// (the Github REST api) if the results are not contained within the cache.
///
/// This class is useful because it provides a single interface to the data
/// layer. You could add an additional layer of disk caching, for example, and
/// the consumer of this service would not require any changes!
class SearchService {
  final SearchCache cache;
  final SearchClient client;

  SearchService({
    SearchCache cache,
    SearchClient client,
  })  : this.cache = cache ?? SearchCache(),
        this.client = client ?? SearchClient();

  Future<SearchResults> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term);
    } else {
      final result = await client.search(term);

      cache.set(term, result);

      return result;
    }
  }
}
