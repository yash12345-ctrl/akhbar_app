import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/models/trending_video_model.dart';

Future<List<TrendingVideo>> fetchTrendingVideos() async {
  final response = await http.get(
    Uri.parse("${AppConstants.baseUrl}/api/videos/trending"),
    headers: {"accept": "application/json"},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load trending videos');
  }

  final jsonData = response.body;
  var json = jsonDecode(jsonData);

  // The backend returns paginated data, so the list of videos is in 'data'
  if (json['data'] != null) {
    return List<TrendingVideo>.from(
      json['data'].map((v) => TrendingVideo.fromJson(v)),
    );
  } else {
    // Fallback if not paginated
    return List<TrendingVideo>.from(
      json.map((v) => TrendingVideo.fromJson(v)),
    );
  }
}
