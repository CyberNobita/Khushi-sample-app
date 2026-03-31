import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightColor,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return Text(text, style: effectiveStyle);
    }

    final pattern = RegExp(RegExp.escape(normalizedQuery), caseSensitive: false);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: effectiveStyle);
    }

    final children = <TextSpan>[];
    var previousIndex = 0;

    for (final match in matches) {
      if (match.start > previousIndex) {
        children.add(
          TextSpan(
            text: text.substring(previousIndex, match.start),
            style: effectiveStyle,
          ),
        );
      }

      children.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: effectiveStyle?.copyWith(
            color: highlightColor ?? Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      previousIndex = match.end;
    }

    if (previousIndex < text.length) {
      children.add(
        TextSpan(
          text: text.substring(previousIndex),
          style: effectiveStyle,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: children),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
