import 'package:akhbar/components/section_title.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  final String title;
  const ArticleScreen({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _ArticleScreen();
}

class _ArticleScreen extends State<ArticleScreen> {
  String articleText = "West bengal ke Governor CV Anand bose ne universities se hafte mein report aur sath hi vice chancellors ko hazir hone ka hukum deya. Raj bhavan ne vice chancellors ko letter likha lakin uske baad bhi report nahi di gai. gauratalab ho ki pichle april mein bengal ke governor cv anand bose ka ek patr raajy ke sabhi universities ke chancellors ko bheja gaya tha.\n\nCBI ne yesterday ko Trinamool All India General Secretary Abhishek Banerjee se question ki.";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Color(0xFFEDE9E9),
          ),
          child: Column(
            children: [
              const Image(
                image: NetworkImage("https://images.unsplash.com/photo-1588681664899-f142ff2dc9b1?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    Expanded(child: SectionTitle(title: "Bal Vivah ki khelaf govt kaam kre ge, Smriti Irani")),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage("https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&auto=format&fit=crop&w=687&h=687&q=80"),
                        ),
                        SizedBox(width: 12,),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Article author name and designation
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ashfaque",
                                    style: TextStyle(
                                      color: Color(AppColors.BLACK_03),
                                      fontSize: 16,
                                      fontFamily: "BarlowCondensed",
                                    ),
                                  ),
                                  Text(
                                    "Editor",
                                    style: TextStyle(
                                      color: Color(AppColors.BLACK_08),
                                      fontSize: 14,
                                      fontFamily: "BarlowCondensed",
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "02/05/2023",
                                style: TextStyle(
                                  color: Color(AppColors.BLACK_04),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "BarlowCondensed",
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),

              ////////////////////////////////////////////////
              // Article body text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        articleText,
                        style: const TextStyle(
                          color: Color(AppColors.BLACK_03),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: "BarlowCondensed",
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // To push bottom CTA to the bottom edge of the screen.
              Expanded(child: Container()),

              ////////////////////////////////////////////
              // Bottom CTA
              Container(
                padding: const EdgeInsets.only(top: 24, right: 16, bottom: 16, left: 16),
                decoration: const BoxDecoration(
                  color: Color(AppColors.BLACK_01),
                  // @TODO
                  // image: DecorationImage(
                  //   image: NetworkImage("https://images.unsplash.com/photo-1588681664899-f142ff2dc9b1?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bal Vivah ki khelaf govt kaam kre ge, Smriti Irani",
                      style: TextStyle(
                        color: Color(AppColors.WHITE),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: "BarlowCondensed",
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tap to know more",
                          style: TextStyle(
                            color: Color(AppColors.WHITE),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            fontFamily: "BarlowCondensed",
                          ),
                        ),

                        // Ad tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(AppColors.WHITE),
                          ),
                          child: const Text(
                            "Akhbar Ad",
                            style: TextStyle(
                              color: Color(AppColors.BLACK_03),
                              fontSize: 12,
                              fontFamily: "BarlowCondensed",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}