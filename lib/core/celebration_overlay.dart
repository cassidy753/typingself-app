/// Celebration Overlay — enhanced confetti/fireworks animation for stage completion.
///
/// Renders a full-screen overlay with 100+ animated particles (confetti dots,
/// stars, sparkles) with varied colors, haptic-like scale pulses, and
/// smooth fade-out. Uses only Flutter's built-in animation — no extra deps.
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

  // Haptic-like pulse timings
  static const _pulseTimes = [0.15, 0.35, 0.55, 0.72, 0.85];

  @override
  void initState() {
    super.initState();

    // Generate 120 particles — more than triple the original 40
    for (int i = 0; i < 120; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 3 + _random.nextDouble() * 16,
        color: _randomColor(),
        delay: _random.nextDouble() * 0.8,
        speed: 0.2 + _random.nextDouble() * 1.2,
        isStar: _random.nextDouble() < 0.15,
        isSparkle: _random.nextDouble() < 0.12 && _random.nextDouble() >= 0.15,
        drift: (_random.nextDouble() - 0.5) * 1.5,
        wobble: _random.nextDouble() * 2.0,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Main scale-in with elastic bounce
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Fade in quickly, hold, then fade out
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // Haptic-like pulsing: micro scale jolts at key moments

    _controller.forward();
  }

  Color _randomColor() {
    // Daebi palette + extended range for celebration variety
    const colors = [
      Color(0xFFE0785A), // Coral
      Color(0xFFD4A843), // Mustard
      Color(0xFF9B72AA), // Purple
      Color(0xFF8FA87A), // Sage
      Color(0xFFFF6B9D), // Pink
      Color(0xFF6BC5D0), // Teal
      Color(0xFFFFB347), // Orange
      Color(0xFFE8505B), // Red
      Color(0xFF5C7AFF), // Blue
      Color(0xFFFFD93D), // Gold
      Color(0xFFAD6BFF), // Violet
      Color(0xFF2ECC71), // Emerald
      Color(0xFFFF8A5C), // Peach
      Color(0xFF7ED6DF), // Sky
      Color(0xFFF8A5C2), // Rose
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Compute haptic-like scale jolt at a given progress value.
  double _computeHapticScale(double progress) {
    double pulse = 1.0;
    for (final t in _pulseTimes) {
      final dist = (progress - t).abs();
      if (dist < 0.08) {
        // Sharp micro-pulse: scale jumps 1.08 → 1.0 over 0.08s
        pulse = 1.0 + (0.08 * (1.0 - dist / 0.08));
      }
    }
    return pulse;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final hapticScale = _computeHapticScale(progress);
        final fadeOpacity = _fadeAnim.value * (1.0 - (progress > 0.7
            ? (progress - 0.7) / 0.3
            : 0.0));

        return Stack(
          children: [
            // ── Particles ──
            ..._particles.map((p) => _buildParticle(p)),

            // ── Center content with haptic-like pulsing ──
            Center(
              child: Opacity(
                opacity: fadeOpacity,
                child: Transform.scale(
                  scale: _scaleAnim.value * hapticScale,
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
                        // Animated emoji with micro-bounce
                        Transform.scale(
                          scale: 1.0 + 0.06 * sin(progress * pi * 6),
                          child: Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 56),
                          ),
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

    // Enhanced particle physics
    final yOffset = -(progress * 350 * p.speed);
    // Add wobble effect
    final wobble = sin(progress * pi * p.wobble * 3) * 30 * p.drift;
    final xOffset = sin(progress * pi * 2) * 20 * p.drift + wobble;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Haptic-like micro-pulse per particle
    final particlePulse = 0.6 + 0.4 * sin(progress * pi * 4 * (1 + p.wobble));
    final scale = (0.2 + progress * 0.6) * particlePulse;

    // Determine particle shape
    final isSparkle = p.isSparkle;
    final isStar = p.isStar;

    return Positioned(
      left: MediaQuery.of(context).size.width * p.x + xOffset,
      top: MediaQuery.of(context).size.height * p.y + yOffset,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: isSparkle
              ? _buildSparkle(p)
              : isStar
                  ? _buildStar(p)
                  : _buildDot(p),
        ),
      ),
    );
  }

  Widget _buildDot(_Particle p) {
    return Container(
      width: p.size,
      height: p.size,
      decoration: BoxDecoration(
        color: p.color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        // Add subtle glow
        boxShadow: [
          BoxShadow(
            color: p.color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildStar(_Particle p) {
    return Container(
      width: p.size * 1.5,
      height: p.size * 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [p.color, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: p.color.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '✨',
          style: TextStyle(fontSize: p.size * 0.8),
        ),
      ),
    );
  }

  Widget _buildSparkle(_Particle p) {
    // Sparkle: small diamond shape
    return Transform.rotate(
      angle: _controller.value * pi * 2,
      child: Container(
        width: p.size,
        height: p.size * 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              p.color.withValues(alpha: 0.0),
              p.color.withValues(alpha: 0.9),
              p.color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Particle {
  final double x, y, size, delay, speed, drift, wobble;
  final Color color;
  final bool isStar;
  final bool isSparkle;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.delay,
    required this.speed,
    required this.isStar,
    required this.isSparkle,
    required this.drift,
    required this.wobble,
  });
}
