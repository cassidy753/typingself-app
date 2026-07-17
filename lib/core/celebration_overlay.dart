/// Celebration Overlay — confetti/fireworks animation for stage completion.
///
/// Renders a full-screen overlay with animated particles (confetti dots + stars)
/// that fades out after a few seconds. Uses only Flutter's built-in animation
/// and flutter_animate — no extra dependencies.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CelebrationOverlay extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  const CelebrationOverlay({
    super.key,
    this.emoji = '🎉',
    this.title = 'Stage 完成！',
    this.subtitle = '繼續下一步旅程',
    this.accent = AppColors.cta,
  });

  /// Show the celebration overlay and auto-dismiss after [duration].
  static Future<void> show(
    BuildContext context, {
    String emoji = '🎉',
    String title = 'Stage 完成！',
    String subtitle = '繼續下一步旅程',
    Color accent = AppColors.cta,
    Duration duration = const Duration(seconds: 4),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => CelebrationOverlay(
        emoji: emoji,
        title: title,
        subtitle: subtitle,
        accent: accent,
      ),
    );
    // Auto-dismiss
    await Future.delayed(duration);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  final _random = Random();
  final _particles = <_Particle>[];

  @override
  void initState() {
    super.initState();

    // Generate particles
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 4 + _random.nextDouble() * 10,
        color: _randomColor(),
        delay: _random.nextDouble() * 0.8,
        speed: 0.3 + _random.nextDouble() * 0.7,
        isStar: _random.nextDouble() < 0.2,
        drift: (_random.nextDouble() - 0.5) * 1.0,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Color _randomColor() {
    const colors = [
      Color(0xFFE0785A), // Coral
      Color(0xFFD4A843), // Mustard
      Color(0xFF9B72AA), // Purple
      Color(0xFF8FA87A), // Sage
      Color(0xFF5C4033), // Brown
      Color(0xFFFF6B9D), // Pink
    ];
    return colors[_random.nextInt(colors.length)];
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
      builder: (context, _) {
        return Stack(
          children: [
            // ── Particles ──
            ..._particles.map((p) => _buildParticle(p)),
            // ── Center content ──
            Center(
              child: Opacity(
                opacity: _fadeAnim.value * (1.0 - (_controller.value > 0.7
                    ? (_controller.value - 0.7) / 0.3
                    : 0.0)),
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: 0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticle(_Particle p) {
    final progress = (_controller.value - p.delay).clamp(0.0, 1.0);
    if (progress <= 0) return const SizedBox();

    final yOffset = -(progress * 300 * p.speed);
    final xOffset = sin(progress * pi * 2) * 20 * p.drift;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 0.3 + progress * 0.7;

    return Positioned(
      left: MediaQuery.of(context).size.width * p.x + xOffset,
      top: MediaQuery.of(context).size.height * p.y + yOffset,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: p.size,
            height: p.size,
            decoration: BoxDecoration(
              color: p.isStar ? null : p.color.withValues(alpha: 0.8),
              shape: p.isStar ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: p.isStar ? null : BorderRadius.circular(2),
              gradient: p.isStar
                  ? LinearGradient(
                      colors: [p.color, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: p.isStar
                ? Center(
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: p.size * 1.2),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double x, y, size, delay, speed, drift;
  final Color color;
  final bool isStar;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.delay,
    required this.speed,
    required this.isStar,
    required this.drift,
  });
}
