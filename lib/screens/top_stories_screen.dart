import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/article_screen_bag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopStoriesScreen extends StatefulWidget {
  final ArticleScreenBag data;
  final VoidCallback? onClose;
  const TopStoriesScreen({super.key, required this.data, this.onClose});

  @override
  State<TopStoriesScreen> createState() => _TopStoriesScreenState();
}

class _TopStoriesScreenState extends State<TopStoriesScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.data.articleList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (widget.onClose != null) {
        widget.onClose!();
      } else if (context.canPop()) {
        context.pop(); // End of stories
      } else {
        context.goNamed("home");
      }
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (widget.onClose != null) {
        widget.onClose!();
      } else if (context.canPop()) {
        context.pop(); // First story, just exit
      } else {
        context.goNamed("home");
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
    _animationController.stop();
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final articles = widget.data.articleList;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: _onTapDown,
            onLongPress: _pauseTimer,
            onLongPressUp: _resumeTimer,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(), // Allow manual swiping
              itemCount: articles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildStory(article);
              },
            ),
          ),
          
          // Progress Bars
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                children: articles.asMap().entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: _buildProgressBar(entry.key),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Close Button
            Positioned(
              top: 60,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed("home");
                  }
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildProgressBar(int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (index == _currentIndex)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    height: 3,
                    width: constraints.maxWidth * _animationController.value,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            if (index < _currentIndex)
              Container(
                height: 3,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStory(Article article) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        if (article.imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: article.imageUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
          )
        else
          Container(color: Colors.grey[900]),

        // Dark gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Text Content
        Positioned(
          bottom: 80,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(AppColors.PRIMARY),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "TOP STORY",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  article.titleUr.isNotEmpty ? article.titleUr : article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to article
                    widget.data.activeArticleIndex = _currentIndex;
                    widget.data.activeArticle = article;
                    context.goNamed("article", extra: widget.data);
                  },
                  child: const Text(
                    "Read Article",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
