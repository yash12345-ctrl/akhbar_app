import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class ViewAllLink extends StatelessWidget {
  final void Function()? onPressed;
  const ViewAllLink({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(AppColors.PRIMARY).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "VIEW ALL",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(AppColors.PRIMARY),
                fontFamily: "BarlowCondensed",
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: Color(AppColors.PRIMARY),
            ),
          ],
        ),
      ),
    );
  }
}