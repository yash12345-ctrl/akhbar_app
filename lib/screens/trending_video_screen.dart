import 'package:akhbar/apis/trending_video_api.dart';
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/models/article_screen_bag.dart';
import 'package:akhbar/models/trending_video_model.dart';
import 'package:akhbar/components/error_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class TrendingVideoScreen extends StatefulWidget {
  final String title;
  final ArticleScreenBag? data;
  final VoidCallback? onClose;

  const TrendingVideoScreen({super.key, required this.title, this.data, this.onClose});

  @override
  State<TrendingVideoScreen> createState() => _TrendingVideoScreenState();
}

class _TrendingVideoScreenState extends State<TrendingVideoScreen> {
  late Future<List<TrendingVideo>> videos;
  int _currentIndex = 0; // Track the currently visible page to auto-play/pause

  @override
  void initState() {
    super.initState();
    videos = fetchTrendingVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for reels feel
      extendBodyBehindAppBar: true, // Edge-to-edge
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white, // White text to stand out against videos
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: widget.onClose,
            ),
        ],
      ),
      body: FutureBuilder<List<TrendingVideo>>(
        future: videos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SafeArea(child: ErrorMessage(message: "Failed to load videos"));
          } else if (!snapshot.hasData) {
            // Full screen skeleton loader for Reels
            return Shimmer.fromColors(
              baseColor: Colors.grey[900]!,
              highlightColor: Colors.grey[800]!,
              child: Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end, // RTL
                  children: [
                    Container(
                      height: 20,
                      width: 200,
                      margin: const EdgeInsets.only(bottom: 16, right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 15,
                      width: 150,
                      margin: const EdgeInsets.only(bottom: 40, right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final videoList = snapshot.data!;
          if (videoList.isEmpty) {
            return const SafeArea(child: ErrorMessage(message: "No trending videos found."));
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videoList.length,
            physics: const ClampingScrollPhysics(), // Snap feel
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final video = videoList[index];
              return ReelVideoPlayer(
                video: video,
                isVisible: index == _currentIndex,
              );
            },
          );
        },
      ),
    );
  }
}

class ReelVideoPlayer extends StatefulWidget {
  final TrendingVideo video;
  final bool isVisible;

  const ReelVideoPlayer({super.key, required this.video, required this.isVisible});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      String urlStr = widget.video.videoUrl;
      print("RAW VIDEO URL: $urlStr");
      if (!urlStr.startsWith('http')) {
        if (urlStr.startsWith('/')) {
          urlStr = AppConstants.baseUrl + urlStr;
        } else {
          urlStr = "${AppConstants.baseUrl}/$urlStr";
        }
      }
      print("FINAL VIDEO URL: $urlStr");
      final uri = Uri.parse(urlStr);
      _controller = VideoPlayerController.networkUrl(uri);
      
      // Initialize first, then set looping to avoid native exceptions
      await _controller!.initialize();
      await _controller!.setLooping(true);
      _isInitialized = true;
      
      if (widget.isVisible) {
        _controller!.play();
        _isPlaying = true;
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing video: $e");
      _hasError = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-play / Auto-pause when visibility changes
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        if (_isInitialized && _controller != null) {
          _controller!.play();
        }
        _isPlaying = true;
      } else {
        if (_isInitialized && _controller != null) {
          _controller!.pause();
        }
        _isPlaying = false;
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  String _getThumbnailUrl() {
    if (widget.video.thumbnailUrl == null || widget.video.thumbnailUrl!.isEmpty) {
      return '';
    }
    String urlStr = widget.video.thumbnailUrl!;
    if (!urlStr.startsWith('http')) {
      if (urlStr.startsWith('/')) {
        urlStr = AppConstants.baseUrl + urlStr;
      } else {
        urlStr = "${AppConstants.baseUrl}/$urlStr";
      }
    }
    return urlStr;
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = _getThumbnailUrl();
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Thumbnail Placeholder
        if (thumbnailUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[900]),
            errorWidget: (context, url, error) => Container(color: Colors.black),
          )
        else
          Container(color: Colors.black87),

        // 2. Video Player Surface
        if (_isInitialized && !_hasError && _controller != null)
          GestureDetector(
            onTap: _togglePlayPause,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
        // If not initialized, allow tapping to retry or just absorb taps
        if (!_isInitialized || _hasError)
          GestureDetector(
            onTap: _isInitialized ? _togglePlayPause : null,
            child: Container(color: Colors.transparent),
          ),

        // 3. Dark Gradient Overlay (bottom up) to make text readable
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4), // slight dark at top for app bar
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),

        // 4. Play Button / Loading Indicator Overlay (when paused or loading)
        if (!_isPlaying || !_isInitialized)
          Center(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: _isInitialized
                        ? const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50)
                        : _hasError
                            ? const Icon(Icons.error_outline, color: Colors.redAccent, size: 50)
                            : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),

        // 5. Title and Description Overlay (Bottom area)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40, top: 40),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.video.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        widget.video.description,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
