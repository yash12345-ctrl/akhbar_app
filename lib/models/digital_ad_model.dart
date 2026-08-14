import 'dart:convert';

class DigitalAd {
  final int id;
  final String uuid;
  final String title;
  final String? description; // nullable
  final String ctaUrl;
  final String mediaUrl;
  final int mediaKind;
  final int adKind;
  final String adUrl;
  final int advertiserId;
  final String expiresAt;
  final String createdAt;

  DigitalAd({
    required this.id,
    required this.uuid,
    required this.title,
    this.description,
    required this.ctaUrl,
    required this.mediaUrl,
    required this.mediaKind,
    required this.adKind,
    required this.adUrl,
    required this.advertiserId,
    required this.expiresAt,
    required this.createdAt,
  });

  String createdAtDate() {
    return "02/05/2023";
  }

  factory DigitalAd.fromJson(Map<String, dynamic> json) {
    return DigitalAd(
      id: json["id"],
      uuid: json["uuid"],
      title: json["title"],
      ctaUrl: json["cta_url"],
      mediaUrl: json["media_url"],
      mediaKind: json["media_kind"] as int,
      adKind: json["ad_kind"] as int,
      adUrl: json["ad_url"],
      advertiserId: json["advertiser_id"] as int,
      expiresAt: json["expires_at"],
      createdAt: json["created_at"],
      description: json["description"],
    );
  }
}

List<DigitalAd> digitalAdsFromJson(String json) {
  final data = jsonDecode(json);

  return List<DigitalAd>.from(data["data"].map((item) => DigitalAd.fromJson(item)));
}