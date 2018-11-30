class SearchResultsError {
  final String message;
  final String documentationUrl;

  SearchResultsError({this.message, this.documentationUrl});

  factory SearchResultsError.fromJson(Map<String, dynamic> json) {
    return SearchResultsError(
      message: json['message'],
      documentationUrl: json['documentation_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['documentation_url'] = this.documentationUrl;
    return data;
  }
}
