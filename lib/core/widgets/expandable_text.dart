import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders text clamped to [maxLines] (default 2) with a smooth 'Read more' / 'Read less' button or custom [onReadMoreTap] action.
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextStyle? toggleStyle;
  final TextAlign textAlign;
  final VoidCallback? onReadMoreTap;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 2,
    this.style,
    this.toggleStyle,
    this.textAlign = TextAlign.start,
    this.onReadMoreTap,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();

    final defaultStyle = widget.style ??
        const TextStyle(
          color: AppColors.text,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45,
        );

    final toggleTextStyle = widget.toggleStyle ??
        const TextStyle(
          color: Color(0xFF1E6091),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure text height to determine if clamping is needed
        final textSpan = TextSpan(text: widget.text, style: defaultStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: widget.maxLines,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(
            widget.text,
            style: defaultStyle,
            textAlign: widget.textAlign,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.text,
                style: defaultStyle,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                textAlign: widget.textAlign,
              ),
              secondChild: Text(
                widget.text,
                style: defaultStyle,
                textAlign: widget.textAlign,
              ),
            ),
            const SizedBox(height: 3),
            InkWell(
              onTap: () {
                if (widget.onReadMoreTap != null && !_isExpanded) {
                  widget.onReadMoreTap!();
                } else {
                  setState(() => _isExpanded = !_isExpanded);
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  _isExpanded ? 'Read less' : 'Read more',
                  style: toggleTextStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
