
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/data/blocs/article_tts_bloc.dart';
import 'package:akhbar/data/blocs/article_tts_state.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/article_tts_model.dart';
import 'package:akhbar/widgets/snackbars.dart';
import 'package:akhbar/widgets/stream_loading_indicator.dart';
import 'package:akhbar/apis/article_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../audio_controller.dart';

class ArticlePage extends StatefulWidget {
  final Article article;
  final AudioController audioController;
  const ArticlePage({super.key, required this.article, required this.audioController});

  @override
  State<StatefulWidget> createState() => _ArticlePage();
}

class _ArticlePage extends State<ArticlePage> {
  ArticleTTSBloc bloc = ArticleTTSBloc();
  ArticleTTS? _articleTTS;
  Article? _fullArticle;
  bool isActiveHindustani = false;
  bool _isPlaying = false;

  void _onListenArticle(Article article) async {
    if (_articleTTS == null) {
      bloc.articleTTSState.add(ArticleTTSFetchState(id: article.id));
    } else {
      if (_isPlaying) {
        widget.audioController.pauseSound();
        setState(() {
          _isPlaying = false;
        });
      } else {
        _playSound(_articleTTS!);
      }
    }
  }

  void _playSound(ArticleTTS articleTTS) async {
    await widget.audioController.playSound(articleTTS.url);
    bloc.isLoadingState.add(false);
    setState(() {
      _isPlaying =  true;
    });
  }

  void _disposeSoundSource() {
    widget.audioController.stopSound();
  }

  void _handleEvents() async {
    bloc.articleTTSFeedbackSubject.listen((event) {
      if (event is ArticleTTSFetchSuccessState) {
        _articleTTS = event.articleTTS;
        _playSound(_articleTTS!);
      } else if (event is ArticleTTSFetchFailureState) {
        errorMessage(context, event.message);
      }
    });
  }

  void _initSound() async {
    // @NOTE This Future.delayed is a hack to solve the pause button not coming
    // back to play after finishing playing in the UI.
    // This happens because the dispose() of previous page is called after the
    // init() of new screen causing the onPlayEnded callback set to null as
    // dispose is called late the new onPlayEnded callback is overridden by the
    // old dispose.
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      widget.audioController.onPlayEnded(() {
        setState(() {
          _isPlaying = false;
        });
      });
    });
  }

  @override
  void initState() {
    _initSound();
    _handleEvents();
    _fetchFullArticle();
    super.initState();
  }

  void _fetchFullArticle() async {
    try {
      final article = await fetchArticle(widget.article.id);
      if (mounted) {
        setState(() {
          _fullArticle = article;
        });
      }
    } catch (e) {
      // Use widget.article as fallback
    }
  }

  @override
  void dispose() {
    _disposeSoundSource();
    super.dispose();
  }

  shortenToFitShortContent(text, {int limit = 250}) {
    if (text.length < limit) {
      return text;
    }

    return "${text.substring(0, limit - 5)}..." ;
  }

  @override
  Widget build(BuildContext context) {
    final displayArticle = _fullArticle ?? widget.article;
    final title = !isActiveHindustani ? displayArticle.titleUr : displayArticle.titleEn;
    final contentText = !isActiveHindustani ? displayArticle.contentShortUr : displayArticle.contentShortEn;
    final rtl = !isActiveHindustani;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                // Hero Image
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.article.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Content Area
                Container(
                  margin: const EdgeInsets.only(top: 360),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.PRIMARY).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(AppColors.PRIMARY)),
                                const SizedBox(width: 8),
                                Text(
                                  widget.article.createdAtDate(),
                                  style: const TextStyle(
                                    color: Color(AppColors.PRIMARY),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Play Button
                          StreamLoadingIndicator(
                            isProcessing: bloc.isLoading,
                            child: GestureDetector(
                              onTap: () => _onListenArticle(widget.article),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(AppColors.PRIMARY),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: const Color(AppColors.PRIMARY).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                                  ],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Language Segmented Control
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Light slate color
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isActiveHindustani = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isActiveHindustani ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: !isActiveHindustani
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Urdu",
                                      style: TextStyle(
                                        color: !isActiveHindustani ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                        fontWeight: !isActiveHindustani ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isActiveHindustani = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isActiveHindustani ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: isActiveHindustani
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "English",
                                      style: TextStyle(
                                        color: isActiveHindustani ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                        fontWeight: isActiveHindustani ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Directionality(
                        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F141E),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Author Row
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage('assets/img/a1.png'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Akhbar-e-Mashriq",
                                style: TextStyle(
                                  color: Color(0xFF0F141E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Editor",
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Article Content
                      Directionality(
                        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                        child: Text(
                          shortenToFitShortContent(contentText, limit: 1000),
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 19,
                            fontWeight: FontWeight.w400,
                            height: 1.9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Source
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Text(
                          "Source: ${widget.article.source}",
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final url = Uri.parse(displayArticle.articleUrl);
                              try { launchUrl(url); } catch (e) {
                                //
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.public_rounded, color: Color(0xFF64748B), size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Read full story on web",
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Directionality(
                                          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                                          child: Text(
                                            shortenToFitShortContent(title, limit: 50),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: context.pop,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F141E), size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
