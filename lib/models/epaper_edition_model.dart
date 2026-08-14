import 'dart:convert';

class EPaperEdition {
  final Map<String, String> editions;

  // @TODO EPaperEdition writer


  EPaperEdition({
    required this.editions,
  });

  factory EPaperEdition.fromJson(Map<String, String> json) {
    return EPaperEdition(
      editions: json,
    );
  }

  String dateToHumanReadable() {
    // @TODO: Generate human readable time string from createdAt
    return "5hr ago";
  }

  Map<String, String> toJson() {
    return editions;
  }

  @override
  String toString() {
    return 'EPaperEdition{$editions}';
  }
}

EPaperEdition ePaperEditionsFromJson(String jsonData) {
  final data = jsonDecode(jsonData);

  return EPaperEdition(editions: data);
}