import 'dart:convert';

enum MediaKind {
  VIDEO,
}

class Poll {
  final int id;
  final String title;
  final String description;
  final String question;
  final String mediaUrl;
  final int mediaKind;
  final String status;
  final String publishedAt;
  final String createdAt;

  // @TODO Poll writer


  Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.question,
    required this.mediaUrl,
    required this.mediaKind,
    required this.status,
    required this.publishedAt,
    required this.createdAt,
  });

  String createdAtDate() {
    return "02/05/2023";
  }

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      question: json["question"],
      mediaUrl: json["media_url"],
      mediaKind: json["media_kind"],
      status: json["status"].toString(),
      publishedAt: json["published_at"],
      createdAt: json["created_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title, "description": description, "question": question, "media_url": mediaUrl, "media_kind": mediaKind, "status": status, "published_at": publishedAt};
  }

  @override
  String toString() {
    return 'Poll{id: $id, name: $title, description: $description, question: $question, media_url: $mediaUrl, media_kind: $mediaKind, status: $status, published_at: $publishedAt, created_at: $createdAt}';
  }
}

List<Poll> pollsFromJson(String jsonData) {
  final data = jsonDecode(jsonData);

  return List<Poll>.from(data["data"].map((item) => Poll.fromJson(item)));
}

Poll pollFromJson(String jsonData) {
  final data = jsonDecode(jsonData);

  return Poll.fromJson(data);
}