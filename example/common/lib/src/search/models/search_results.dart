import 'package:common/src/search/models/repo.dart';

class SearchResults {
  final int totalCount;
  final bool incompleteResults;
  final List<Repo> items;

  SearchResults({this.totalCount, this.incompleteResults, this.items});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      totalCount: json['total_count'],
      incompleteResults: json['incomplete_results'],
      items: json['items']
              ?.cast<Map<String, dynamic>>()
              ?.map<Repo>((item) => Repo.fromJson(item))
              ?.toList() ??
          [],
    );
  }

  bool get isEmpty => items.isEmpty;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['incomplete_results'] = this.incompleteResults;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
