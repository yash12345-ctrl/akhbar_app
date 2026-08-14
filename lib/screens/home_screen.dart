import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/apis/auth_api.dart';
import 'package:akhbar/apis/category_api.dart';
import 'package:akhbar/apis/poll_api.dart';
import 'package:akhbar/components/article_horizontal_card.dart';
import 'package:akhbar/components/error_message.dart';
import 'package:akhbar/components/poll_button.dart';
import 'package:akhbar/components/result_progress_bar.dart';
import 'package:akhbar/components/section_title.dart';
import 'package:akhbar/components/top_app_menu_bar.dart';
import 'package:akhbar/components/view_all_link.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/exceptions/http_auth_exception.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/article_screen_bag.dart';
import 'package:akhbar/models/category_model.dart';
import 'package:akhbar/models/poll_model.dart';
import 'package:akhbar/models/poll_vote_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

final List<String> baseMenuList = [ "All" ];
List<String> menuList = List.from(baseMenuList);

class _HomeScreen extends State<HomeScreen> {

  late Future<List<Category>> articleCategories;
  late Future<List<Article>> articles;
  List<Poll>? _polls;
  Poll? _activePoll;
  PollVote? _activePoleVote;
  int _activeCategoryIndex = 0;

  fetchPollsAndSetActive() async {
    try {
      _polls = await fetchPolls();
    } on HttpAuthException {
      await logout();
      if (!mounted) return;
      context.goNamed("signin");
    } catch (error) {
      // ignore the polls
      return;
    }
    if (_polls != null && _polls!.isNotEmpty) {
      setState(() {
        _activePoll = _polls![0];
      });
    }
  }

  _sendUserVoteForPoll(int vote) async {
    if (_activePoll != null) {
      try {
        var voteRes = (await postUserPollVote(_activePoll!, vote));
        setState(() {
          _activePoleVote = voteRes;
        });

      } catch (error) {
        // @TODO Send error to server
        print(error);
      }
    }
  }

  Future<void> _initArticles() async {
    setState(() {
      articles = fetchArticles();
    });
  }

  Future<void> _onRefreshArticles() async {
    List<Article>? oldList;
    try {
      oldList = await articles;
    } catch (_) {}

    Future<List<Article>> newArticlesFuture;
    if (_activeCategoryIndex == 0) {
      newArticlesFuture = fetchArticles();
    } else {
      var categories = await articleCategories;
      newArticlesFuture = fetchArticles(categoryId: categories[_activeCategoryIndex - 1].id);
    }

    setState(() {
      articles = newArticlesFuture;
    });

    try {
      var newList = await newArticlesFuture;
      bool isNew = true;
      if (oldList != null && oldList.isNotEmpty && newList.isNotEmpty) {
        if (oldList.first.id == newList.first.id) {
          isNew = false;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            backgroundColor: isNew ? const Color(AppColors.PRIMARY) : const Color(0xFF1E293B),
            elevation: 10,
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isNew ? Icons.autorenew_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isNew ? "Refresh Complete" : "All Caught Up",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isNew ? "New stories have been loaded." : "You've seen all the latest articles.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {}
  }

  void init() {
    _initArticles();
    articleCategories = fetchCategories();
    fetchPollsAndSetActive();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/img/a2-mobile.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AKHBAR",
                          style: TextStyle(
                            fontFamily: "serif",
                            fontSize: 24,
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F141E),
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "E-MASHRIQ",
                          style: TextStyle(
                            fontFamily: "BarlowCondensed",
                            fontSize: 12,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700,
                            color: Color(AppColors.PRIMARY),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFF0F0F0), height: 1),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: articleCategories,
                  builder: (BuildContext context, snapshot) {
                    var categories = snapshot.data;
                    if (categories != null) {
                      menuList.clear();
                      menuList.addAll(baseMenuList);
                      for (var element in categories) {
                        menuList.add(element.name_en);
                      }
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: menuList.length,
                      itemBuilder: (context, index) {
                        final isActive = _activeCategoryIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _activeCategoryIndex = index;
                            });
                            Navigator.pop(context); // Close drawer
                            if (index == 0) {
                              setState(() {
                                articles = fetchArticles();
                              });
                            } else {
                              setState(() {
                                articles = fetchArticles(categoryId: categories![index - 1].id);
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(AppColors.PRIMARY).withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (isActive)
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(AppColors.PRIMARY),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    margin: const EdgeInsets.only(right: 12),
                                  ),
                                Expanded(
                                  child: Text(
                                    menuList[index],
                                    style: TextStyle(
                                      fontFamily: "BarlowCondensed",
                                      fontSize: 18,
                                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                      color: isActive ? const Color(AppColors.PRIMARY) : const Color(0xFF444444),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: isActive ? const Color(AppColors.PRIMARY) : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: TopAppMenuBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "AKHBAR-E-MASHRIQ",
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: "serif",
                    fontSize: 18,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F141E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefreshArticles,
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // @TODO Implement article search feature
                  // const SearchNewsBox(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionTitle(title: "Popular today",),
                        FutureBuilder(future: articles, builder: (BuildContext context, snapshot) {
                          var articleListInternal = snapshot.data;
                          if (articleListInternal == null) {
                            return Container();
                          }

                          return ViewAllLink(onPressed: () {
                            ArticleScreenBag data = ArticleScreenBag(
                              activeArticle: articleListInternal[0],
                              activeArticleIndex: 0,
                              articleList: articleListInternal,
                            );
                            // @TODO: Pass the data by deep copy.
                            context.goNamed("article", extra: data);
                          });
                        }),
                      ],
                    ),
                  ),

                  ///////////////////////////////////////
                  // Articles
                  FutureBuilder<List<Article>>(
                    future: articles,
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasError) {
                        return const ErrorMessage(
                          message: "Something bad happened",
                        );
                      } else if (!snapshot.hasData) {
                        return Padding(
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
                                      Container(
                                        width: 100,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: double.infinity,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 100,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }

                      var articles = snapshot.data;
                      if (articles == null || articles.isEmpty) {
                        return const ErrorMessage(message: "No articles found");
                      }

                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          var singleArticle = articles[index];
                          return ArticleHorizontalCard(article: singleArticle, articleIndex: index, onPressed: (article) {

                            ArticleScreenBag data = ArticleScreenBag(
                              activeArticle: singleArticle,
                              activeArticleIndex: index,
                              articleList: articles,
                            );
                            // @TODO: Pass the data by deep copy.
                            context.goNamed("article", extra: data);
                          });
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 8);
                        },
                        itemCount: articles.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const ClampingScrollPhysics(),
                      );
                    },
                  ),

                  //////////////////////////////////////////////
                  // Polls
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionTitle(title: "Polls",),
                        ViewAllLink(onPressed: () {}),
                      ],
                    ),
                  ),

                  if (_polls != null)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180.0, enableInfiniteScroll: true,
                        onPageChanged: (int i, CarouselPageChangedReason reason) {
                          setState(() {
                            _activePoll = _polls![i];
                            _activePoleVote = null;
                          });
                        },
                      ),
                      items: _polls!.map((poll) {
                        String pollImageUrl = poll.mediaUrl;
                        // print(poll['image_url']);
                        // return Container();
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                // color: Colors.amber,
                                image: DecorationImage(
                                  image: NetworkImage(pollImageUrl),
                                  scale: 2,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),
                  if (_activePoll != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              _activePoll!.title,
                              style: const TextStyle(
                                color: Color(AppColors.BLACK_03),
                                fontFamily: "BarlowCondensed",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  if (_activePoll != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              _activePoll!.question,
                              style: const TextStyle(
                                color: Color(AppColors.BLACK_03),
                                fontFamily: "BarlowCondensed",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                  if (_activePoll != null && _activePoleVote == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // @TODO Use the answer from activePoll variable
                          Expanded(
                            child: PollButton(
                              buttonText: "Yes",
                              onPressed: () {
                                // 1 = Yes (first answer)
                                _sendUserVoteForPoll(1);
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: PollButton(
                              buttonText: "No",
                              onPressed: () {
                                // 2 = No (second answer)
                                _sendUserVoteForPoll(2);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_activePoleVote != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ResultProgressBar(
                        progress: 50,
                        child: Text(
                          "${_activePoleVote!.yesCount} Yes / ${_activePoleVote!.noCount} No",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(AppColors.BLACK_03),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: "BarlowCondensed",
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 100), // Extra padding for floating bottom bar

                ],
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}