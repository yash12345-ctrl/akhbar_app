import 'package:akhbar/apis/article_api.dart';
import 'package:akhbar/apis/epaper_api.dart';
import 'package:akhbar/components/error_message.dart';
import 'package:akhbar/components/top_app_menu_bar.dart';
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/article_model.dart';
import 'package:akhbar/models/epaper_mode.dart';
import 'package:akhbar/models/category_model.dart';
import 'package:akhbar/apis/category_api.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EPaperScreen extends StatefulWidget {
  final String title;
  const EPaperScreen({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _EPaperScreen();
}

class _EPaperScreen extends State<EPaperScreen> {

  late Future<List<Article>> articles;
  late Future<List<EPaper>> epapers;
  late Future<List<Category>> articleCategories;
  final List<String> baseMenuList = ["All"];
  final List<String> menuList = [];
  int _activeCategoryIndex = 0;

  static const platform = MethodChannel(AppConstants.methodChannel);

  Future<void> enableScreenCapture() async {
    try {
      await platform.invokeMethod(AppConstants.enableScreenCaptureMethod);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> disableScreenCapture() async {
    try {
      await platform.invokeMethod(AppConstants.disableScreenCaptureMethod);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void init() {
    articles = fetchArticles();
    epapers = fetchEPapers();
    articleCategories = fetchCategories();
  }

  @override
  void initState() {
    init();
    enableScreenCapture();
    super.initState();
  }

  @override
  void dispose() {
    disableScreenCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        showBackButton: false,
        title: const SizedBox(
          child: Text(
            "E-News Paper",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F141E),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                ///////////////////////////////////////
                // Articles
                FutureBuilder<List<EPaper>>(
                  future: epapers,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return const ErrorMessage(
                        message: "Something bad happened",
                      );
                    } else if (!snapshot.hasData) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildSkeleton();
                        },
                      );
                    }

                    var epapers = snapshot.data;
                    if (epapers == null || epapers.isEmpty) {
                      return const ErrorMessage(message: "No e-papers found");
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: epapers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        var singleEPaper = epapers[index];
                        return CachedNetworkImage(
                          imageUrl: singleEPaper.imageUrl,
                          placeholder: (context, url) => _buildSkeleton(),
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFEEEEEE), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        useSafeArea: false,
                                        builder: (context) {
                                          return Dialog.fullscreen(
                                            backgroundColor: Colors.black,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: InteractiveViewer(
                                                    panEnabled: true,
                                                    minScale: 0.5,
                                                    maxScale: 6,
                                                    child: Image(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: MediaQuery.of(context).padding.top + 10,
                                                  right: 20,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.5),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                                                      onPressed: () => Navigator.of(context).pop(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Container(
                                        color: const Color(0xFFF0F0F0),
                                        child: InteractiveViewer(
                                          panEnabled: true,
                                          minScale: 0.5,
                                          maxScale: 6,
                                          child: Image(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF888888)),
                                        const SizedBox(width: 8),
                                        Text(
                                          singleEPaper.createdAtDate(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF888888),
                                            fontFamily: AppConstants.fontName,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        final url = Uri.parse("${AppConstants.baseUrl}/epaper/${singleEPaper.id}");
                                        try {
                                          await launchUrl(url, mode: LaunchMode.externalApplication,);
                                        } catch (error) {}
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(AppColors.PRIMARY).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          children: [
                                            Text(
                                              "Read online",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(AppColors.PRIMARY),
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward_rounded, size: 16, color: Color(AppColors.PRIMARY)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      errorWidget: (context, url, error) => const ErrorMessage(message: "Failed to load image"),
                    );
                  },
                    );
                  },
                ),

                const SizedBox(height: 32),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.white,
            child: Container(
              height: 350,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.white,
                  child: Container(
                    height: 20,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.white,
                  child: Container(
                    height: 36,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
