import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  const ErrorMessage({super.key, required this.message});

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(AppColors.RED_01),
                fontSize: 16,
                fontFamily: AppConstants.fontName,

              ),
            ),
          ),
        ],
      ),
    );
  }
}