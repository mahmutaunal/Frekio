import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class FrekioPalette {
  static const ink = Color(0xFF111020);
  static const violet = Color(0xFF5D5BE6);
  static const violetLight = Color(0xFF9B94FF);
  static const cyan = Color(0xFF4DD8FF);
  static const pink = Color(0xFFFF78D5);
  static const midnight = Color(0xFF090817);
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? FrekioPalette.midnight : const Color(0xFFF8F7FF),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -170,
            right: -140,
            width: 410,
            height: 410,
            child: _AmbientOrb(colors: [Color(0x665D5BE6), Color(0x005D5BE6)]),
          ),
          Positioned(
            top: 250,
            left: -210,
            width: 430,
            height: 430,
            child: _AmbientOrb(
              colors: dark
                  ? const [Color(0x3D4DD8FF), Color(0x004DD8FF)]
                  : const [Color(0x454DD8FF), Color(0x004DD8FF)],
            ),
          ),
          Positioned(
            bottom: -240,
            right: -170,
            width: 470,
            height: 470,
            child: _AmbientOrb(
              colors: dark
                  ? const [Color(0x33FF78D5), Color(0x00FF78D5)]
                  : const [Color(0x3DFF78D5), Color(0x00FF78D5)],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? const [Color(0x12000000), Color(0x66000000)]
                    : const [Color(0x00FFFFFF), Color(0x4DFFFFFF)],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    ),
  );
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    this.padding,
    this.blur = 24,
    this.clear = false,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final bool clear;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final highContrast = MediaQuery.highContrastOf(context);
    final fillOpacity = highContrast
        ? (dark ? 0.82 : 0.9)
        : clear
        ? (dark ? 0.25 : 0.34)
        : (dark ? 0.48 : 0.6);
    final borderColor = dark
        ? Colors.white.withValues(alpha: highContrast ? 0.34 : 0.2)
        : Colors.white.withValues(alpha: highContrast ? 0.96 : 0.74);

    final glass = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      const Color(0xFF343249).withValues(alpha: fillOpacity),
                      const Color(0xFF161522).withValues(alpha: fillOpacity),
                    ]
                  : [
                      Colors.white.withValues(alpha: fillOpacity + 0.1),
                      const Color(0xFFECEAFF).withValues(alpha: fillOpacity),
                    ],
            ),
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );

    if (!shadow) return glass;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.34)
                : FrekioPalette.ink.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: dark ? 0.04 : 0.45),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: glass,
    );
  }
}

class ContentSurface extends StatelessWidget {
  const ContentSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.selected = false,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: selected
            ? FrekioPalette.violet.withValues(alpha: dark ? 0.28 : 0.13)
            : (dark
                  ? const Color(0xFF1E1D2B).withValues(alpha: 0.82)
                  : Colors.white.withValues(alpha: 0.76)),
        border: Border.all(
          color: selected
              ? FrekioPalette.violetLight.withValues(alpha: 0.48)
              : (dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.9)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.055),
            blurRadius: selected ? 18 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

class LiquidPressable extends StatefulWidget {
  const LiquidPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  State<LiquidPressable> createState() => _LiquidPressableState();
}

class _LiquidPressableState extends State<LiquidPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    ),
  );
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.selected = false,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SizedBox(
      width: size,
      height: size,
      child: Material(
        color: selected
            ? FrekioPalette.violet.withValues(alpha: 0.86)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.46),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            icon,
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}
