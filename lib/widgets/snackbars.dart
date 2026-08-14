import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

void validationErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

void successMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: const Color(AppColors.GREEN_05),
          )
      ),
    ),
  );
}

void errorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: const Color(AppColors.RED_05),
          )
      ),
    ),
  );
}