import 'package:akhbar/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileImage extends StatelessWidget
{
  String? imageUrl;
  ProfileImage({super.key, this.imageUrl, this.width = 52, this.height = 52 });

  final double width;
  final double height;

  onProfileImagePressed(BuildContext context) {
    context.pushNamed("profile");
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: GestureDetector(
        onTap: () {
          onProfileImagePressed(context);
        },
        child: Image(
          fit: BoxFit.fitHeight,
          image: NetworkImage(imageUrl != null ? imageUrl! : "${AppConstants.baseUrl}/assets/img/profile-pic.jpg"),
          width: width,
          height: height,
        ),
      ),
    );
  }
}