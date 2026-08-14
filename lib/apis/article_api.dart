import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akhbar/helpers/device_id_helper.dart';
import 'package:akhbar/models/article_tts_model.dart';
import 'package:http/http.dart' as http;
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/models/article_model.dart';

// Cache deviceId at module level so we only call getDeviceId() once per session
String? _cachedDeviceId;
Future<String> _getDeviceId() async {
  _cachedDeviceId ??= await DeviceIdHelper.getDeviceId();
  return _cachedDeviceId!;
}

Future<List<Article>> fetchArticles({ int page = 1, int? categoryId, String searchQuery = '' }) async {
  String cacheKey = "cached_articles_page_${page}_cat_${categoryId ?? 'all'}_q_$searchQuery";
  try {
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    if (categoryId != null && categoryId != 0) queryParams['category_id'] = categoryId.toString();
    if (searchQuery.isNotEmpty) queryParams['q'] = searchQuery;

    final uri = Uri.parse(AppConstants.apiArticleUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: {"accept": "application/json"});

    if (response.statusCode != 200) {
      throw Exception("Failed to load articles");
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, response.body);

    return articleFromJson(response.body);
  } catch (e) {
    // Only fall back to cache for non-search requests
    if (searchQuery.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        return articleFromJson(cachedData);
      }
    }
    throw Exception("Failed to load articles");
  }
}

Future<List<Article>> fetchMyFeed({ int page = 1, String searchQuery = '' }) async {
  String cacheKey = "cached_my_feed_page_${page}_q_$searchQuery";
  try {
    String deviceId = await _getDeviceId();

    final queryParams = <String, String>{'page': page.toString()};
    if (searchQuery.isNotEmpty) queryParams['q'] = searchQuery;

    final uri = Uri.parse("${AppConstants.apiArticleUrl}/my-feed").replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        "X-Device-ID": deviceId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load my feed");
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, response.body);

    return articleFromJson(response.body);
  } catch (e) {
    // Only fall back to cache for non-search, first page requests
    if (searchQuery.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        return articleFromJson(cachedData);
      }
    }
    throw Exception("Failed to load my feed");
  }
}

Future<void> trackArticleView(int articleId) async {
  try {
    String deviceId = await _getDeviceId();
    await http.post(
      Uri.parse("${AppConstants.apiArticleUrl}/$articleId/track-view"),
      headers: {
        "accept": "application/json",
        "X-Device-ID": deviceId,
      },
    );
  } catch (e) {
    // Fail silently since it's just analytics tracking
  }
}

Future<Article> fetchArticle(int id) async {
  final String cacheKey = "cached_article_detail_$id";
  try {
    final response = await http.get(
      Uri.parse("${AppConstants.apiArticleUrl}/$id"),
      headers: {"accept": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load article details");
    }

    // Cache the result for future offline access
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, response.body);

    final jsonData = response.body;
    var json = jsonDecode(jsonData);
    return Article.fromJson(json["article"]);
  } catch (e) {
    // Fallback to cache
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      var json = jsonDecode(cachedData);
      return Article.fromJson(json["article"]);
    }
    throw Exception("Failed to load article details");
  }
}

Future<ArticleTTS> fetchArticleTTS(int id) async {
  final response = await http.get(
    Uri.parse(AppConstants.apiArticleTTSUrl.replaceAll("ARTICLE_ID", id.toString())),
    headers: {"accept": "application/json"},
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to generate speech");
  }
  final jsonData = response.body;
  var json = jsonDecode(jsonData);

  return ArticleTTS.fromJson(json);
}