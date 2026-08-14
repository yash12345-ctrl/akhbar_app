import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ArticleHorizontalCard extends StatefulWidget {
  final Article article;
  int? articleIndex;
  void Function(Article) onPressed;
  final bool showEnglishTitle;
  ArticleHorizontalCard({super.key, required this.article, required this.onPressed, this.articleIndex, this.showEnglishTitle = false});
  @override
  State<StatefulWidget> createState() => _ArticleHorizontalCard();
}

class _ArticleHorizontalCard extends State<ArticleHorizontalCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed(widget.article);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF2F2F2), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.article.imageUrl,
                fit: BoxFit.cover,
                width: 120,
                height: 90,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 90,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 90,
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: widget.showEnglishTitle ? TextDirection.ltr : TextDirection.rtl,
                    child: Text(
                      widget.showEnglishTitle && widget.article.titleEn.isNotEmpty 
                          ? widget.article.titleEn 
                          : widget.article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: widget.showEnglishTitle ? null : AppConstants.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.5,
                        color: const Color(0xFF0F141E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              widget.article.dateToHumanReadable(),
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: "BarlowCondensed",
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.bookmark_border_rounded, size: 18, color: Colors.grey.shade400),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}