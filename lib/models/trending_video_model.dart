class TrendingVideo {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int status;
  final String createdAt;

  TrendingVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.status,
    required this.createdAt,
  });

  factory TrendingVideo.fromJson(Map<String, dynamic> json) {
    return TrendingVideo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
