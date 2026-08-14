import 'dart:async';

import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/components/top_app_menu_bar.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/article_screen_bag.dart';
import 'package:akhbar/models/category_model.dart';
import 'package:akhbar/apis/category_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class MyFeedScreen extends StatefulWidget {
  final String title;
  const MyFeedScreen({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _MyFeedScreen();
}

class _MyFeedScreen extends State<MyFeedScreen> {
  // --- Article list state ---
  final List<Article> _articles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  // --- Category state ---
  List<Category> _categories = [];
  final List<String> _menuList = ["My Feed"];
  int _activeCategoryIndex = 0;

  // --- Search state ---
  String _searchQuery = "";
  Timer? _searchDebounceTimer;
  final TextEditingController _searchController = TextEditingController();

  // --- Scroll controller for infinite scroll ---
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadArticles(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoadingMore &&
          _hasMore &&
          !_isLoading) {
        _loadMoreArticles();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  // --- Data Loading ---

  Future<void> _loadCategories() async {
    try {
      final cats = await fetchCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _menuList.clear();
          _menuList.add("My Feed");
          for (var c in cats) {
            _menuList.add(c.name_en);
          }
        });
      }
    } catch (_) {
      // categories are optional, don't crash
    }
  }

  Future<void> _loadArticles({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _articles.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final result = await _fetchCurrentFeed(page: 1);
      if (mounted) {
        setState(() {
          _articles.addAll(result);
          _isLoading = false;
          _currentPage = 1;
          _hasMore = result.length >= 20; // assume page size 20
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll("Exception: ", "");
        });
      }
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await _fetchCurrentFeed(page: nextPage);
      if (mounted) {
        setState(() {
          _articles.addAll(result);
          _currentPage = nextPage;
          _hasMore = result.length >= 20;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to load more articles"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<List<Article>> _fetchCurrentFeed({required int page}) {
    if (_activeCategoryIndex == 0) {
      return fetchMyFeed(page: page, searchQuery: _searchQuery);
    } else {
      final category = _categories[_activeCategoryIndex - 1];
      return fetchArticles(
        page: page,
        categoryId: category.id,
        searchQuery: _searchQuery,
      );
    }
  }

  Future<void> _onRefreshArticles() async {
    final List<Article> oldArticles = List.from(_articles);
    await _loadArticles(reset: true);

    final bool isNew = _articles.isNotEmpty &&
        (oldArticles.isEmpty || _articles[0].id != oldArticles[0].id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundColor: isNew ? const Color(AppColors.PRIMARY) : const Color(0xFF1E293B),
          elevation: 10,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNew ? Icons.check_circle_outline : Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isNew ? "Refresh Complete" : "All Caught Up",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isNew ? "Latest articles loaded" : "No new stories right now",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      _loadArticles(reset: true);
    });
  }

  void _onCategorySelected(int index) {
    if (index == _activeCategoryIndex) return;
    Navigator.pop(context); // Close drawer
    setState(() {
      _activeCategoryIndex = index;
    });
    _loadArticles(reset: true);
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(),
      appBar: TopAppMenuBar(
        title: const SizedBox(
          child: Text(
            "My Feed",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefreshArticles,
            color: const Color(AppColors.PRIMARY),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Search bar
                SliverToBoxAdapter(child: _buildSearchBar()),

                // Main content
                if (_isLoading)
                  SliverToBoxAdapter(child: _buildShimmerGrid())
                else if (_errorMessage != null)
                  SliverFillRemaining(child: _buildErrorState())
                else if (_articles.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  _buildArticlesGrid(),

                // Load more indicator
                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(AppColors.PRIMARY),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Sub-widgets ---

  Widget _buildDrawer() {
    return Drawer(
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
                      child: Image.asset("assets/img/a2-mobile.png", fit: BoxFit.cover),
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
              child: _menuList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _menuList.length,
                      itemBuilder: (context, index) {
                        final isActive = _activeCategoryIndex == index;
                        return InkWell(
                          onTap: () => _onCategorySelected(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(AppColors.PRIMARY).withValues(alpha: 0.08)
                                  : Colors.transparent,
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
                                    _menuList[index],
                                    style: TextStyle(
                                      fontFamily: "BarlowCondensed",
                                      fontSize: 18,
                                      fontWeight:
                                          isActive ? FontWeight.w800 : FontWeight.w600,
                                      color: isActive
                                          ? const Color(AppColors.PRIMARY)
                                          : const Color(0xFF444444),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: isActive
                                      ? const Color(AppColors.PRIMARY)
                                      : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Search news, topics, or stories...",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                      _loadArticles(reset: true);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 0.7,
          ),
          itemCount: 12,
          itemBuilder: (context, index) => Container(color: Colors.white),
        ),
      ),
    );
  }

  SliverGrid _buildArticlesGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final article = _articles[index];
          return _buildArticleTile(article, index);
        },
        childCount: _articles.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.7,
      ),
    );
  }

  Widget _buildArticleTile(Article article, int index) {
    return GestureDetector(
      onTap: () {
        final data = ArticleScreenBag(
          activeArticle: article,
          activeArticleIndex: index,
          articleList: _articles,
        );
        context.pushNamed("article", extra: data);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: article.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? "Something went wrong",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadArticles(reset: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.PRIMARY),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? "No articles match \"$_searchQuery\""
                  : "No articles found",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}