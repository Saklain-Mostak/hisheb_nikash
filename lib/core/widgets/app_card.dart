import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final double borderRadius;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.borderRadius = 20,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveBorder = border ??
        Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        );

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? theme.cardTheme.color)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
