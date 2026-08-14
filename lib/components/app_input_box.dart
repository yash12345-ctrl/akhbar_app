import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class AppInputBox extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const AppInputBox({
    super.key,
    this.hintText,
    required this.controller,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  State<AppInputBox> createState() => _AppInputBox();
}

class _AppInputBox extends State<AppInputBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        cursorColor: const Color(AppColors.PRIMARY),
        style: const TextStyle(
          color: Color(0xFF111111),
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF111111).withValues(alpha: 0.4),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: const Color(0xFF111111).withValues(alpha: 0.4),
                  size: 22,
                )
              : null,
          fillColor: const Color(0xFFF7F7F7),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: const Color(0xFF111111).withValues(alpha: 0.05),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Color(AppColors.PRIMARY),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}