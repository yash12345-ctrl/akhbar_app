import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class Article {
  static const LANG_BOTH = 3;

  final int id;
  final String title;
  final String titleEn;
  final String titleUr;
  final String contentShort;
  final String contentShortEn;
  final String contentShortUr;
  final String imageUrl;
  final String articleUrl;
  final String source;
  final int visibleIn;
  final int categoryId;
  final String createdAt;

  // @TODO Article writer


  Article({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.titleUr,
    required this.contentShort,
    required this.contentShortEn,
    required this.contentShortUr,
    required this.imageUrl,
    required this.articleUrl,
    required this.source,
    required this.visibleIn,
    required this.categoryId,
    required this.createdAt,
  });

  String createdAtDate() {
    final d = DateTime.parse(createdAt);
    final f = DateFormat("d/M/y");
    return f.format(d);
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json["id"] ?? 0,
      title: json["title_ur"] ?? "",
      titleEn: json["title_en"] ?? "",
      titleUr: json["title_ur"] ?? "",
      contentShort: json["content_ur"] ?? json["content_short_ur"] ?? "--",
      contentShortEn: json["content_en"] ?? json["content_short_en"] ?? "--",
      contentShortUr: json["content_ur"] ?? json["content_short_ur"] ?? "--",
      imageUrl: json["image_url"] ?? "",
      articleUrl: json["article_url"] ?? "",
      source: json["source"] ?? "",
      visibleIn: json["visible_in"] ?? 3,
      categoryId: json["category_id"] ?? 0,
      createdAt: json["created_at"] ?? DateTime.now().toIso8601String(),
    );
  }

  String dateToHumanReadable() {
    final t = DateTime.parse(createdAt);
    // @TODO: Generate human readable time string from createdAt
    return "${timeago.format(t, locale: 'en_short')} ago";
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title, "title_en": titleEn, "title_ur": titleUr, "content_short": contentShort, "content_short_en": contentShortEn, "content_short_ur": contentShortUr, "image_url": imageUrl, "article_url": articleUrl, "source": source, "visible_in": visibleIn, "category_id": categoryId, "created_at": createdAt};
  }

  @override
  String toString() {
    return 'Article{id: $id, title: $title, titleEn: $titleEn, titleUr: $titleUr, contentShort: $contentShort, contentShortEn: $contentShortEn, contentShortUr: $contentShortUr, imageUrl: $imageUrl, articleUrl: $articleUrl, source: $source, visible_in: $visibleIn, categoryId: $categoryId, createdAt: $createdAt}';
  }

  bool isVisibleInBothLang() {
    return visibleIn == LANG_BOTH;
  }
}

List<Article> articleFromJson(String jsonData) {
  final data = jsonDecode(jsonData);

  return List<Article>.from(data["data"].map((item) => Article.fromJson(item)));
}