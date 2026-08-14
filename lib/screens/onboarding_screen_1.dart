
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen1 extends StatefulWidget {
  final String title;
  const OnboardingScreen1({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _OnboardingScreen1();
}

class _OnboardingScreen1 extends State<OnboardingScreen1>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _progressController;

  late Animation<double> _headerFade;
  late Animation<double> _contentFade;
  late Animation<double> _bottomFade;
  late Animation<double> _lineSweep;

  List<Article> _articles = [];
  int _currentArticleIndex = 0;
  Timer? _articleTimer;
  AnimationController? _cardController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _lineSweep = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.1, 0.55, curve: Curves.easeOut),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _entryController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _progressController.forward();
    });

    _loadArticles();
    loginOrHome();
  }

  Future<void> _loadArticles() async {
    try {
      // 1. Try to load from cache immediately so UI shows articles instantly
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('splash_articles_cache');
      
      if (cachedString != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(cachedString);
          final cachedArticles = jsonList.map((j) => Article.fromJson(j)).toList();
          if (mounted && _articles.isEmpty) {
            setState(() {
              _articles = cachedArticles.take(4).toList();
            });
            _startArticleRotation();
          }
        } catch (_) {
          // ignore cache parsing errors
        }
      }

      // 2. Fetch fresh articles from the network
      final articles = await fetchArticles();
      if (!mounted) return;
      
      final top4 = articles.take(4).toList();
      
      // Save top 4 to cache for next time
      try {
        prefs.setString('splash_articles_cache', jsonEncode(top4.map((a) => a.toJson()).toList()));
      } catch (_) {}

      setState(() {
        _articles = top4;
      });
      
      // If we didn't start rotation from cache, start it now
      if (_articleTimer == null) {
        _startArticleRotation();
      }
    } catch (_) {
      // silently ignore if network fails, cache will remain on screen
    }
  }

  void _startArticleRotation() {
    _articleTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!mounted || _articles.isEmpty) return;
      setState(() {
        _currentArticleIndex = (_currentArticleIndex + 1) % _articles.length;
      });
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _progressController.dispose();
    _cardController?.dispose();
    _articleTimer?.cancel();
    super.dispose();
  }

  loginOrHome() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    context.goNamed("home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Red accent line sweeping from left ────────────────────────
          AnimatedBuilder(
            animation: _lineSweep,
            builder: (_, __) => Container(
              height: 3,
              width: MediaQuery.of(context).size.width * _lineSweep.value,
              color: const Color(AppColors.PRIMARY),
            ),
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // ── HEADER: Name left, Logo right ──────────────────────
                  FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 20, 0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
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
                                const SizedBox(height: 16),
                                // Masthead
                                const Text(
                                  "MASHRIQ",
                                  style: TextStyle(
                                    fontFamily: "serif",
                                    fontSize: 34,
                                    letterSpacing: 6.0,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F141E),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  width: 20,
                                  height: 1.5,
                                  color: const Color(0xFFE0E0E0),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "EST. 1980",
                                  style: TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 4.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),

                  // Removed the harsh divider line to let the design breathe
                  const SizedBox(height: 16),

                  // ── MIDDLE: Expanded article card fills all space ──────
                  Expanded(
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section label
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(AppColors.PRIMARY),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "LATEST NEWS",
                                  style: TextStyle(
                                    fontFamily: "BarlowCondensed",
                                    fontSize: 11,
                                    letterSpacing: 2.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Article card with AnimatedSwitcher slide transition
                            Expanded(
                              child: _articles.isEmpty
                                  ? _buildSkeletonCard()
                                  : AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 600),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        // Slide in from right, slide out to left
                                        final offsetAnimation = Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ));
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _buildArticleCard(
                                        _articles[_currentArticleIndex],
                                        // unique key triggers AnimatedSwitcher on change
                                        key: ValueKey(_currentArticleIndex),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 12),

                            // Dot indicators
                            if (_articles.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _articles.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: i == _currentArticleIndex ? 18 : 6,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: i == _currentArticleIndex
                                          ? const Color(AppColors.PRIMARY)
                                          : const Color(0xFFDDDDDD),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),

                            // ── BOTTOM: tagline + dot loader ──────────
                            FadeTransition(
                              opacity: _bottomFade,
                              child: Column(
                                children: [
                                  Container(
                                      height: 0.8,
                                      color: const Color(0xFFEEEEEE)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Your Urdu & Hindustani News Source",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "BarlowCondensed",
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFAAAAAA),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (_, __) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(3, (i) {
                                          final progress =
                                              _progressController.value;
                                          final isActive = progress > i / 3;
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            width: isActive ? 22 : 7,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? const Color(
                                                      AppColors.PRIMARY)
                                                  : const Color(0xFFE0E0E0),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article, {Key? key}) {
    final title = article.titleEn.isNotEmpty ? article.titleEn : article.title;
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
          children: [
            // ── Full-bleed image fills the entire card ────────────
            Positioned.fill(
              child: article.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _fallbackBg(),
                      placeholder: (context, url) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            _fallbackBg(),
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : _fallbackBg(),
            ),

            // ── Gradient overlay: transparent top → dark bottom ──────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Color(0xDD111111),
                    ],
                  ),
                ),
              ),
            ),

            // ── Top-left: LATEST badge ──────────────────────────
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(AppColors.PRIMARY),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "LATEST",
                  style: TextStyle(
                    fontFamily: "BarlowCondensed",
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ── Top-right: time badge ───────────────────────────
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 10, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      article.dateToHumanReadable(),
                      style: const TextStyle(
                        fontFamily: "BarlowCondensed",
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom: title text on top of dark gradient ────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: "BarlowCondensed",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Thin red accent line below title
                    Container(
                      width: 36,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.PRIMARY),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  // Fallback when image is missing
  Widget _fallbackBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.15,
          child: Image.asset(
            "assets/img/a2-mobile.png",
            width: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFEEEEEE),
      ),
      child: Stack(
        children: [
          // Skeleton shimmer-style rows at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}