import 'package:akhbar/models/article_tts_model.dart';

class ArticleTTSState {}

class ArticleTTSFetchState extends ArticleTTSState {
  int id;
  ArticleTTSFetchState({ required this.id });
}

class ArticleTTSFetchSuccessState extends ArticleTTSState {
  final ArticleTTS articleTTS;
  ArticleTTSFetchSuccessState({ required this.articleTTS });
}

class ArticleTTSFetchFailureState extends ArticleTTSState {
  final String message;
  ArticleTTSFetchFailureState({ required this.message });
}
