// import 'dart:math' as math;

// import 'package:flutter/material.dart';

// import '../core/constants/app_colors.dart';
// import '../core/constants/app_sizes.dart';

// class Shimmer extends StatefulWidget {
//   final Widget child;
//   const Shimmer({super.key, required this.child});

//   @override
//   State<Shimmer> createState() => _ShimmerState();
// }

// class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         final shimmerPosition = _controller.value * 2 * math.pi;
//         return ShaderMask(
//           shaderCallback: (rect) {
//             return LinearGradient(
//               colors: [
//                 AppColors.overlay,
//                 AppColors.overlay.withOpacity(0.35),
//                 AppColors.overlay,
//               ],
//               stops: const [0.1, 0.3, 0.4],
//               begin: Alignment(-1 - math.cos(shimmerPosition), -1),
//               end: Alignment(1 + math.sin(shimmerPosition), 1),
//             ).createShader(rect);
//           },
//           blendMode: BlendMode.srcATop,
//           child: child,
//         );
//       },
//       child: widget.child,
//     );
//   }
// }

// class ShimmerBox extends StatelessWidget {
//   final double height;
//   final double width;
//   final double radius;
//   const ShimmerBox({super.key, required this.height, this.width = double.infinity, this.radius = AppSizes.inputRadius});

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer(
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           color: AppColors.card,
//           borderRadius: BorderRadius.circular(radius),
//         ),
//       ),
//     );
//   }
// }

// class ShimmerListPlaceholder extends StatelessWidget {
//   final int rows;
//   final double itemHeight;
//   const ShimmerListPlaceholder({super.key, this.rows = 6, this.itemHeight = 72});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: List.generate(
//         rows,
//         (i) => Padding(
//           padding: const EdgeInsets.only(bottom: AppSizes.sm),
//           child: ShimmerBox(height: itemHeight, radius: AppSizes.cardRadius),
//         ),
//       ),
//     );
//   }
// }

// class ShimmerCardPlaceholder extends StatelessWidget {
//   final double height;
//   final int lines;
//   const ShimmerCardPlaceholder({super.key, this.height = 120, this.lines = 3});

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer(
//       child: Container(
//         padding: const EdgeInsets.all(AppSizes.md),
//         decoration: BoxDecoration(
//           color: AppColors.card,
//           borderRadius: BorderRadius.circular(AppSizes.cardRadius),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: List.generate(
//             lines,
//             (index) => Padding(
//               padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : AppSizes.sm),
//               child: ShimmerBox(
//                 height: 12,
//                 width: index == 0 ? 140 : double.infinity,
//                 radius: 8,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ShimmerGridPlaceholder extends StatelessWidget {
//   final int count;
//   const ShimmerGridPlaceholder({super.key, this.count = 4});

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: AppSizes.sm,
//       runSpacing: AppSizes.sm,
//       children: List.generate(
//         count,
//         (index) => SizedBox(
//           width: 180,
//           child: const ShimmerCardPlaceholder(height: 90, lines: 2),
//         ),
//       ),
//     );
//   }
// }

// class ListLoading extends StatelessWidget {
//   final int rows;
//   final double itemHeight;
//   final EdgeInsets padding;
//   const ListLoading({super.key, this.rows = 6, this.itemHeight = 72, this.padding = const EdgeInsets.all(AppSizes.md)});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: padding,
//       child: ShimmerListPlaceholder(rows: rows, itemHeight: itemHeight),
//     );
//   }
// }

// class CardLoading extends StatelessWidget {
//   final double height;
//   final int lines;
//   final EdgeInsets padding;
//   const CardLoading({super.key, this.height = 140, this.lines = 3, this.padding = const EdgeInsets.all(AppSizes.md)});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: padding,
//       child: ShimmerCardPlaceholder(height: height, lines: lines),
//     );
//   }
// }
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final wave = _controller.value * 2 * math.pi;

        // اللون يتغير حسب الثيم
        final shimmerBase = Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.06);

        final shimmerHighlight = Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 196, 196, 196).withOpacity(0.24)
            : Colors.black.withOpacity(0.12);

        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [shimmerBase, shimmerHighlight, shimmerBase],
              stops: const [0.2, 0.5, 0.8],
              begin: Alignment(-1 - math.cos(wave), -1),
              end: Alignment(1 + math.sin(wave), 1),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = AppSizes.inputRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(radius),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.border),
          )
        ),
      ),
    );
  }
}

class ShimmerListPlaceholder extends StatelessWidget {
  final int rows;
  final double itemHeight;

  const ShimmerListPlaceholder({
    super.key,
    this.rows = 6,
    this.itemHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rows,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: ShimmerBox(height: itemHeight, radius: AppSizes.cardRadius),
        ),
      ),
    );
  }
}

class ShimmerCardPlaceholder extends StatelessWidget {
  final double height;
  final int lines;

  const ShimmerCardPlaceholder({super.key, this.height = 120, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.border),
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            lines,
            (i) => Padding(
              padding: EdgeInsets.only(
                bottom: i == lines - 1 ? 0 : AppSizes.sm,
              ),
              child: ShimmerBox(
                height: 12,
                width: i == 0 ? 140 : double.infinity,
                radius: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerGridPlaceholder extends StatelessWidget {
  final int count;

  const ShimmerGridPlaceholder({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: List.generate(
        count,
        (index) => const SizedBox(
          width: 180,
          child: ShimmerCardPlaceholder(height: 90, lines: 2),
        ),
      ),
    );
  }
}

class ListLoading extends StatelessWidget {
  final int rows;
  final double itemHeight;
  final EdgeInsets padding;

  const ListLoading({
    super.key,
    this.rows = 6,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ShimmerListPlaceholder(rows: rows, itemHeight: itemHeight),
    );
  }
}

class CardLoading extends StatelessWidget {
  final double height;
  final int lines;
  final EdgeInsets padding;

  const CardLoading({
    super.key,
    this.height = 140,
    this.lines = 3,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ShimmerCardPlaceholder(height: height, lines: lines),
    );
  }
}


class TimelineLoading extends StatelessWidget {
  const TimelineLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان Timeline
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: ShimmerBox(height: 18, width: 120),
          ),

          // 3 Steps Shimmer
          ...List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // دائرة + خط
                  Column(
                    children: [
                      Shimmer(
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.card,
                        ),
                      ),
                      if (i != 2)
                        Container(
                          width: 2,
                          height: 40,
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSizes.md),

                  // نصوص الخطوات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(height: 14, width: 140),
                        SizedBox(height: 6),
                        ShimmerBox(height: 12, width: 220),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppSizes.lg),

          // زرار اوبشنز + الدروب داون + النوت
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSizes.sm,
              runSpacing: AppSizes.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                ShimmerBox(height: 38, width: 120, radius: 10), // dropdown
                ShimmerBox(height: 38, width: 160, radius: 10), // note
                ShimmerBox(height: 38, width: 80, radius: 10), // add
                ShimmerBox(height: 38, width: 80, radius: 10), // refresh
              ],
            ),
          ),
        ],
      ),
    );
  }
}

