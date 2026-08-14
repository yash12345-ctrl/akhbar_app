import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class ResultProgressBar extends StatefulWidget {
  Widget child;
  double progress;
  ResultProgressBar({super.key, required this.child, required this.progress});
  @override
  State<StatefulWidget> createState() => _ResultProgressBar();
}

class _ResultProgressBar extends State<ResultProgressBar> {
  // @TODO: Need to complete the implementaiton.
  // currently I am not able to make the progress width variable.
  // I'll comeback here again.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(AppColors.WHITE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(AppColors.CYAN_01),
                    Color(AppColors.GREEN_01),
                  ],
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}