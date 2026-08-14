import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool rtl;
  const SectionTitle({super.key, required this.title, this.rtl = false});

  @override 
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!rtl)
          Container(
            width: 4,
            height: 20,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(AppColors.PRIMARY),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        Flexible(
          child: Text(
            title,
            textAlign: rtl ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F141E),
              fontFamily: "serif",
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (rtl)
          Container(
            width: 4,
            height: 20,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: const Color(AppColors.PRIMARY),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}