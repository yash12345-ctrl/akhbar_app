class ArticleTTS {
  final String url;
  ArticleTTS({
    required this.url,
  });

  factory ArticleTTS.fromJson(Map<String, dynamic> json) {
    return ArticleTTS(
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }

  @override
  String toString() {
    return 'ArticleTTS{url: $url}';
  }
}