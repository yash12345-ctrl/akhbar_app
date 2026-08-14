import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class PollButton extends StatefulWidget {
  final String buttonText;
  final void Function()? onPressed;
  const PollButton({super.key, required this.buttonText, required this.onPressed});

  @override
  State<StatefulWidget> createState() => _PollButton();
}

class _PollButton extends State<PollButton> {

  @override
  build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),

          side: const BorderSide(
            width: 1,
            color: Color(0xFFE3DEDE),
          ),
          shadowColor: Colors.transparent,
        ),
        child: Text(
          widget.buttonText,
          style: const TextStyle(
            fontFamily: "BarlowCondensed",
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.BLACK_03),
          ),
        ),
      ),
    );
  }
}