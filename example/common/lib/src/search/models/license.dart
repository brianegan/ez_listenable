class License {
  final String key;
  final String name;
  final String spdxId;
  final String url;
  final String nodeId;

  License({this.key, this.name, this.spdxId, this.url, this.nodeId});

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      key: json['key'],
      name: json['name'],
      spdxId: json['spdx_id'],
      url: json['url'],
      nodeId: json['node_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['spdx_id'] = this.spdxId;
    data['url'] = this.url;
    data['node_id'] = this.nodeId;
    return data;
  }
}
