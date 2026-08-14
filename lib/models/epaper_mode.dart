import 'package:intl/intl.dart';
import 'dart:convert';

class EPaper {
  final int id;
  final String title;
  final String imageUrl;
  final int edition;
  final String createdAt;

  // @TODO EPaper writer


  EPaper({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.edition,
    required this.createdAt,
  });

  String createdAtDate() {
    final d = DateTime.parse(createdAt);
    final f = DateFormat("d/M/y");
    return f.format(d);
  }

  factory EPaper.fromJson(Map<String, dynamic> json) {
    return EPaper(
      id: json["id"],
      title: json["title"],
      imageUrl: json["image_url"],
      edition: json["edition"],
      createdAt: json["created_at"],
    );
  }

  String dateToHumanReadable() {
    // @TODO: Generate human readable time string from createdAt
    return "5hr ago";
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title, "image_url": imageUrl, "edition": edition, "created_at": createdAt};
  }

  @override
  String toString() {
    return 'EPaper{id: $id, name: $title, imageUrl: $imageUrl, edition: $edition, createdAt: $createdAt}';
  }
}

List<EPaper> ePapersFromJson(String jsonData) {
  final data = jsonDecode(jsonData);

  return List<EPaper>.from(data["data"].map((item) => EPaper.fromJson(item)));
}