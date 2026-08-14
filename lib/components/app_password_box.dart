import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class AppPasswordBox extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;

  const AppPasswordBox({
    super.key,
    this.hintText,
    required this.controller,
    this.prefixIcon,
  });

  @override
  State<AppPasswordBox> createState() => _AppPasswordBox();
}

class _AppPasswordBox extends State<AppPasswordBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: widget.controller,
        cursorColor: const Color(AppColors.PRIMARY),
        obscureText: _obscureText,
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
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFF111111).withValues(alpha: 0.4),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
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