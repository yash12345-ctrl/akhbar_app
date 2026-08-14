import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/apis/digital_ad_api.dart';
import 'package:akhbar/audio_controller.dart';
import 'package:akhbar/components/article_page.dart';
import 'package:akhbar/components/digital_ad_page.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/article_or_digital_ad_model.dart';
import 'package:akhbar/models/article_screen_bag.dart';
import 'package:akhbar/models/digital_ad_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticleScreen extends StatefulWidget {
  final String title;
  int? initialArticleIndex;
  int? categoryId;
  ArticleScreen({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _ArticleScreen();
}

class _ArticleScreen extends State<ArticleScreen> {

  final int articlesPerPage = 20;
  int currentArticleNumber = 1;
  final int closeToEndDiff = 5;
  int currentPage = 1;

  List<Article>? _articles;
  List<DigitalAd>? _digitalAds;

  int distanceFactor = 3;
  int digitalAdIndex = 0;

  ArticleScreenBag? bag;

  List<ArticleOrDigitalAd> articlesAndDigitalAds = [];

  final _audioController = AudioController(); // @TODO This is not the right place to instantiate and initialize


  void _initArticleData(int page) {
    final bag = GoRouterState.of(context).extra as ArticleScreenBag;
    _articles = bag.articleList;
    widget.initialArticleIndex = bag.activeArticleIndex;
    trackArticleView(bag.activeArticle.id);
      if (_articles != null) {
      for (var article in _articles!) {
        articlesAndDigitalAds.add(
          ArticleOrDigitalAd(
            article: article,
            digitalAd: null,
          ),
        );
      }
    }
  }

  void _initDigitalAdData(int page) async {
    try {
        _digitalAds = await fetchDigitalAds();
    } catch (error) {
      // @TODO Handle error
      if (mounted) {
        context.goNamed('home');
      }
    }
  }

  void _fetchMoreArticles(int page) async {
    try {
      List<Article> articles = await fetchArticles(page: page);
      if (articles.isNotEmpty && _articles != null) {
        setState(() {
          final l = List<ArticleOrDigitalAd>.from(articles.map((e) => ArticleOrDigitalAd(article: e, digitalAd: null)));
          articlesAndDigitalAds.addAll(l);
        });
      }
    } catch (error) {
      print(error);
    }
  }

  void onPageChangedInjectAdOrIgnore(int index) {
    if (index < articlesAndDigitalAds.length) {
      final item = articlesAndDigitalAds[index];
      if (item.article != null) {
        trackArticleView(item.article!.id);
      }
    }

    if (index != 0 && index % distanceFactor == 0) {
      if (_digitalAds != null && digitalAdIndex < _digitalAds!.length) {
        final digitalAd = _digitalAds![digitalAdIndex++];
        // @NOTE Injecting new child in list needed to notify the flutter by calling
        // setState() below;
        setState(() {
          articlesAndDigitalAds.insert(index + 1, ArticleOrDigitalAd(article: null, digitalAd: digitalAd));
        });
      }
    }
  }

  void _initAudioController() async {
    await _audioController.initialize();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _initArticleData(1);
    _initDigitalAdData(1);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _initAudioController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _audioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(
      initialPage: widget.initialArticleIndex != null ? widget.initialArticleIndex! : 0,
    );
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        const sensitivity = 8;
        if (details.delta.dx < 0) {
          // print("Swipe LEFT: ${details.delta.dx}");
          // context.goNamed("home");
        } else if (details.delta.dx > 0) {
          // print("Swipe RIGHT: ${details.delta.dx}");
          if (details.delta.dx > sensitivity) {
            context.goNamed("home");
          }
        }
      },
      child: PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        onPageChanged: (int index) {
          onPageChangedInjectAdOrIgnore(index);

          currentArticleNumber = index + 1;
          // print("OK - index $index, currentArticleNumber = $currentArticleNumber, currentPage = $currentPage");
          if (articlesPerPage * currentPage - currentArticleNumber <= 5) {
            // print("FETCH NEXT PAGE ARTICLES");
            currentPage += 1;
            _fetchMoreArticles(currentPage);
          }
        },
        children: articlesAndDigitalAds.map((articleOrDigitalAd) {
          if (articleOrDigitalAd.digitalAd != null) {
            return DigitalAdPage(digitalAd: articleOrDigitalAd.digitalAd ?? _digitalAds![0]);
          }

          return ArticlePage(article: articleOrDigitalAd.article ?? _articles![0], audioController: _audioController,);
        }).toList(),
      ),
    );
  }
}