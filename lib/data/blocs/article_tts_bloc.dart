import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/data/blocs/article_tts_state.dart';
import 'package:rxdart/rxdart.dart';

class ArticleTTSBloc {
  Sink<ArticleTTSState> get articleTTSState => _articleTTSFeedbackSubject.sink;
  Stream<ArticleTTSState> get articleTTSFeedbackSubject => _articleTTSFeedbackSubject.stream;
  final BehaviorSubject<ArticleTTSState> _articleTTSFeedbackSubject = BehaviorSubject<ArticleTTSState>();

  Sink<bool> get isLoadingState => _isLoading.sink;
  Stream<bool> get isLoading => _isLoading.stream;
  final BehaviorSubject<bool> _isLoading = BehaviorSubject<bool>();

  ArticleTTSBloc() {
    _articleTTSFeedbackSubject.stream.listen((event) {
      if (event is ArticleTTSFetchState) {
        _fetchArticleTextToSpeech(event.id);
      }
    });
  }

  void _fetchArticleTextToSpeech(int id) async {
    _isLoading.add(true);
    try {
      final result = await fetchArticleTTS(id);
      _articleTTSFeedbackSubject.add(ArticleTTSFetchSuccessState(articleTTS: result));
    } catch (error) {
      _articleTTSFeedbackSubject.add(ArticleTTSFetchFailureState(message: error.toString()));
    }

    // @NOTE Loading false state moved to the UI layer as the UI layer needs to
    // know when the generated audio URL is loaded.
  }
}