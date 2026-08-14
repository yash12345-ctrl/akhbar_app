import 'package:akhbar/models/article_model.dart';

class ArticleScreenBag {
  Article activeArticle;
  int activeArticleIndex;
  List<Article> articleList;

  ArticleScreenBag({
    required this.activeArticle,
    required this.activeArticleIndex,
    required this.articleList,
  });
}