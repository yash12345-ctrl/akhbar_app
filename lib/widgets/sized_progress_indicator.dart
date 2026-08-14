import 'package:flutter/material.dart';

class SizedProgressIndicator extends StatelessWidget {
  const SizedProgressIndicator({ super.key });

  @override
  Widget build(BuildContext context) {
    return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator()));
  }
}