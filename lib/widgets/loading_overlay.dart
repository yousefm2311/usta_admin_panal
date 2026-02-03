import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final bool blockUI;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.blockUI = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading && blockUI)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: AppColors.background.withOpacity(0.05),
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: isLoading
                ? SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: AppColors.border.withOpacity(0.35),
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
