import 'dart:convert';

class Category {
  final int id;
  final String name_ur;
  final String name_en;
  final String imageUrl;

  // @TODO Category writer


  Category({
    required this.id,
    required this.name_ur,
    required this.name_en,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"] ?? 0,
      name_ur: json["name_ur"] ?? "",
      name_en: json["name_en"] ?? "",
      imageUrl: json["image_url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name_ur": name_ur, "name_en": name_en, "image_url": imageUrl};
  }

  @override
  String toString() {
    return 'Category{id: $id, name_ur: $name_ur, name_en: $name_en, imageUrl: $imageUrl}';
  }
}

List<Category> categoriesFromJson(String jsonData) {
  final data = jsonDecode(jsonData);

  return List<Category>.from(data["data"].map((item) => Category.fromJson(item))).reversed.toList();
}