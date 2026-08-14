import 'package:akhbar/components/section_title.dart';
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/digital_ad_model.dart';
import 'package:flutter/material.dart';

class DigitalAdPage extends StatefulWidget {
  final DigitalAd digitalAd;
  const DigitalAdPage({super.key, required this.digitalAd});

  @override
  State<StatefulWidget> createState() => _DigitalAdPage();
}

class _DigitalAdPage extends State<DigitalAdPage> {

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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.digitalAd.mediaUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Image(
                        image: NetworkImage(widget.digitalAd.mediaUrl),
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: SectionTitle(title: widget.digitalAd.title)),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(AppConstants.defaultImage),
                        ),
                        const SizedBox(width: 12,),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // digitalAd author name and designation
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Akhbar-e-Mashriq",
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
                                widget.digitalAd.createdAtDate(),
                                style: const TextStyle(
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
              // digitalAd body text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.digitalAd.description ?? "",
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
                    Text(
                      widget.digitalAd.title,
                      style: const TextStyle(
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

                        // @TODO @TEMP
                        const SizedBox(width: 190),

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