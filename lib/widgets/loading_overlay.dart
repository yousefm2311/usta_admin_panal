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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        child,
        if (isLoading && blockUI)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: AppColors.background.withOpacity(isDark ? 0.2 : 0.08),
              ),
            ),
          ),
        Positioned(
          top: AppSizes.sm,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: true,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
                      child: child,
                    ),
                  ),
                  child: isLoading
                      ? _LoadingPill(isDark: isDark)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingPill extends StatelessWidget {
  final bool isDark;

  const _LoadingPill({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final spinnerColor = AppColors.primary;
    return Container(
      key: const ValueKey('loading-pill'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(spinnerColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Loading...'.tr,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
