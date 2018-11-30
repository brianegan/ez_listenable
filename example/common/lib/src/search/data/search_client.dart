import 'dart:async';
import 'dart:convert';

import 'package:common/src/search/models/search_results.dart';
import 'package:common/src/search/models/search_results_error.dart';
import 'package:http/http.dart' as http;

/// This is a class that uses an http client to fetch search results from the
/// Github REST api.
class SearchClient {
  final String baseUrl;
  final http.Client client;

  SearchClient({
    http.Client client,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  }) : this.client = client ?? http.Client();

  /// Search Github for repositories using the given term
  Future<SearchResults> search(String term) async {
    final response = await client.get(Uri.parse("$baseUrl$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return SearchResults.fromJson(results);
    } else {
      throw SearchResultsError.fromJson(results);
    }
  }
}
