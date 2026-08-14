import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/components/bottom_app_menu_bar.dart';
import 'package:akhbar/components/top_app_menu_bar.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/article_screen_bag.dart';
import 'package:akhbar/screens/epaper_screen.dart';
import 'package:akhbar/screens/home_screen.dart';
import 'package:akhbar/screens/my_feed_screen.dart';
import 'package:akhbar/screens/top_stories_screen.dart';
import 'package:akhbar/screens/trending_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:upgrader/upgrader.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _articlesFuture = fetchArticles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: TopAppMenuBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "AKHBAR-E-MASHRIQ",
                        maxLines: 1,
                        style: TextStyle(fontFamily: "serif", fontSize: 18, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: Color(0xFF0F141E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Popular today", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F141E))),
                          Container(width: 40, height: 16, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[50]!,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: 100, height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: double.infinity, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(height: 8),
                                        Container(width: double.infinity, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(height: 8),
                                        Container(width: 100, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final articles = snapshot.data!;
        if (articles.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text("No data found"),
            ),
          );
        }

        ArticleScreenBag bag = ArticleScreenBag(
          activeArticle: articles[0],
          activeArticleIndex: 0,
          articleList: articles,
        );

        return UpgradeAlert(
          showIgnore: false,
          showLater: false,
          barrierDismissible: false,
          child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  const HomeScreen(title: "Home"),
                  const MyFeedScreen(title: "My Feed"),
                  TopStoriesScreen(
                    data: bag,
                    onClose: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  TrendingVideoScreen(
                    title: "Trending Videos",
                    onClose: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const EPaperScreen(title: "E-News Paper"),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: (_currentIndex == 2 || _currentIndex == 3) ? -100 : 0,
                left: 0,
                right: 0,
                child: BottomAppMenuBar(
                  activeIndex: _currentIndex,
                  pageController: _pageController,
                  onTabSelected: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}
