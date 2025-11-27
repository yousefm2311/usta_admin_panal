import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'shimmer_widgets.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.7),
              ),
              child: const Center(
                child: ShimmerBox(height: 60, width: 60, radius: 16),
              ),
            ),
          ),
      ],
    );
  }
}
