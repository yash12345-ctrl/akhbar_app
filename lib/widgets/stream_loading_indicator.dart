import 'package:akhbar/widgets/sized_progress_indicator.dart';
import 'package:flutter/material.dart';

class StreamLoadingIndicator extends StatelessWidget {
  final Stream<bool> isProcessing;
  final Widget? child;
  const StreamLoadingIndicator({ super.key, required this.isProcessing, this.child});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(stream: isProcessing, builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (snapshot.hasData && snapshot.data != null && snapshot.data!) {
        return const SizedProgressIndicator();
      }

      return child ?? Container();
    });
  }
}