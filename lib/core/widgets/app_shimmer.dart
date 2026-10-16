import 'package:flutter/material.dart';

/// A pure Flutter, high-performance shimmer effect widget.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double value = _controller.value;
            final double width = bounds.width;
            final double dx = -width + (width * 2 * value);

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: dx / width),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Helper container box for building shimmer skeleton placeholders.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A generic animated list skeleton placeholder with avatar, title, subtitle, and action badge.
class ListShimmerSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ListShimmerSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: padding,
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const ShimmerBox(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 140, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 11, borderRadius: 4),
                  ],
                ),
              ),
              const ShimmerBox(width: 54, height: 22, borderRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

/// A generic single card shimmer skeleton placeholder.
class CardShimmerSkeleton extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry margin;

  const CardShimmerSkeleton({
    super.key,
    this.height = 120,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: height,
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 120, height: 14, borderRadius: 4),
                ShimmerBox(width: 60, height: 20, borderRadius: 6),
              ],
            ),
            ShimmerBox(width: 180, height: 22, borderRadius: 6),
            ShimmerBox(width: 100, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

