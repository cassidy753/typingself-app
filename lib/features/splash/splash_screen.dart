import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../onboarding/greeting_screen.dart';

// 34 個 personality types — 每個有獨立飛行軌跡
final _typeData = <_TypeParticle>[
  // MBTI — 16 types
  _TypeParticle('INTJ', x: -1.8, y: -2.1, z: 3.0, speed: 0.7, size: 28),
  _TypeParticle('INTP', x: 2.2, y: -1.8, z: 4.2, speed: 0.5, size: 24),
  _TypeParticle('ENTJ', x: -0.5, y: -2.8, z: 5.0, speed: 0.4, size: 32),
  _TypeParticle('ENTP', x: 3.0, y: -1.2, z: 2.8, speed: 0.8, size: 22),
  _TypeParticle('INFJ', x: -2.5, y: 0.2, z: 3.5, speed: 0.6, size: 26),
  _TypeParticle('INFP', x: 1.5, y: 0.8, z: 4.8, speed: 0.45, size: 20),
  _TypeParticle('ENFJ', x: -3.2, y: 1.5, z: 2.5, speed: 0.9, size: 30),
  _TypeParticle('ENFP', x: 2.8, y: 1.8, z: 3.8, speed: 0.55, size: 24),
  _TypeParticle('ISTJ', x: -0.8, y: -1.5, z: 5.5, speed: 0.35, size: 18),
  _TypeParticle('ISFJ', x: 3.5, y: -0.5, z: 4.5, speed: 0.5, size: 20),
  _TypeParticle('ESTJ', x: -2.0, y: -0.8, z: 6.0, speed: 0.3, size: 16),
  _TypeParticle('ESFJ', x: 0.5, y: -2.5, z: 5.2, speed: 0.4, size: 18),
  _TypeParticle('ISTP', x: 4.0, y: 0.5, z: 3.2, speed: 0.75, size: 22),
  _TypeParticle('ISFP', x: -1.2, y: 2.2, z: 4.0, speed: 0.6, size: 20),
  _TypeParticle('ESTP', x: 1.0, y: -1.0, z: 6.5, speed: 0.25, size: 14),
  _TypeParticle('ESFP', x: -3.5, y: -1.8, z: 3.0, speed: 0.85, size: 26),
  // Enneagram wings — 18 types
  _TypeParticle('1w9', x: -1.5, y: 2.8, z: 2.0, speed: 1.0, size: 20),
  _TypeParticle('2w1', x: 2.5, y: 2.5, z: 2.5, speed: 0.9, size: 18),
  _TypeParticle('2w3', x: -2.8, y: -0.2, z: 4.8, speed: 0.45, size: 16),
  _TypeParticle('3w2', x: 0.8, y: 3.0, z: 2.2, speed: 1.1, size: 22),
  _TypeParticle('3w4', x: -4.0, y: 0.0, z: 3.5, speed: 0.65, size: 16),
  _TypeParticle('4w3', x: 3.8, y: -2.0, z: 2.8, speed: 0.8, size: 18),
  _TypeParticle('4w5', x: -1.0, y: 3.5, z: 2.0, speed: 1.2, size: 20),
  _TypeParticle('5w4', x: 2.0, y: 3.2, z: 2.5, speed: 1.0, size: 18),
  _TypeParticle('5w6', x: -3.0, y: 2.0, z: 3.0, speed: 0.75, size: 16),
  _TypeParticle('6w5', x: 4.2, y: -2.5, z: 2.5, speed: 0.9, size: 14),
  _TypeParticle('6w7', x: -2.2, y: 3.8, z: 2.0, speed: 1.1, size: 16),
  _TypeParticle('7w6', x: 1.8, y: -3.0, z: 3.5, speed: 0.6, size: 18),
  _TypeParticle('7w8', x: -3.8, y: -2.5, z: 2.8, speed: 0.85, size: 14),
  _TypeParticle('8w7', x: 0.2, y: 3.8, z: 1.8, speed: 1.3, size: 22),
  _TypeParticle('8w9', x: -4.5, y: -1.0, z: 2.5, speed: 0.95, size: 16),
  _TypeParticle('9w8', x: 3.2, y: 3.5, z: 2.0, speed: 1.2, size: 18),
  _TypeParticle('9w1', x: -0.5, y: -3.5, z: 4.0, speed: 0.55, size: 16),
  _TypeParticle('1w2', x: 4.5, y: 1.2, z: 2.2, speed: 1.1, size: 14),
];

class _TypeParticle {
  final String label;
  final double x, y, z;  // 3D position in "world space"
  final double speed;    // 1.0 = normal, >1 = flies faster
  final double size;     // font size when at z=0

  const _TypeParticle(this.label, {required this.x, required this.y, required this.z, required this.speed, required this.size});
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoSlide;

  @override
  void initState() {
    super.initState();

    // Total animation: 3.5s
    // Phase 1 (0%–60%): types fly past camera
    // Phase 2 (50%–90%): logo fades in
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));

    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.linear);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.85, curve: Curves.easeIn)),
    );
    _logoSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic)),
    );

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 4000), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final profileDone = prefs.getBool('profile_done') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => profileDone
          ? const _HomePlaceholder()
          : const GreetingScreen()),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width / 2;
    final h = size.height / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              // ─── Layer 1: Flying type particles ───
              ...List.generate(_typeData.length, (i) {
                final p = _typeData[i];

                // Each particle starts far in Z and flies toward/past camera
                // At progress=0, zStart is in world space
                // At progress=1, z goes to -2 (past camera, behind viewer)
                final rawProgress = _progress.value * 1.4 * p.speed;
                final clamped = rawProgress.clamp(0.0, 1.0);

                // Z: from world-z down to -2 (past camera)
                final zPos = p.z - (p.z + 2.0) * clamped;

                // Perspective projection: scale = 1 / (1 + z * perspectiveFactor)
                // When z is large (far), scale is small
                // When z is negative (past camera), it's behind us (not rendered)
                const persp = 0.08;
                final scale = zPos > 0 ? (1.0 / (1.0 + zPos * persp)) : 0.0;

                // Screen position: project world (x, y) through perspective
                final screenX = w + p.x * 60 * scale;
                final screenY = h + p.y * 40 * scale;

                // Blur: objects close to camera (z near 0) are sharp
                // Objects far away (z large) are blurry
                final blurAmount = (zPos * 1.5).clamp(0.0, 12.0);

                // Opacity: fade out as z goes past 0 (very close or past)
                final alpha = zPos > 0 ? (1.0 - clamped * 0.7).clamp(0.0, 1.0) : 0.0;

                return Positioned(
                  left: screenX - p.size * scale * 0.5,
                  top: screenY - p.size * scale * 0.4,
                  child: Opacity(
                    opacity: alpha,
                    child: ImageFiltered(
                      imageFilter: blurAmount > 0.5
                          ? ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount)
                          : (ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0)),
                      child: Text(
                        p.label,
                        style: GoogleFonts.notoSansTc(
                          fontSize: p.size * scale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                          color: AppColors.primary.withValues(alpha: 0.35 * alpha + 0.15),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // ─── Layer 2: Logo ───
              Center(
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoSlide.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(child: Text('型', style: GoogleFonts.notoSerifTc(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary))),
                        ),
                        const SizedBox(height: 20),
                        Text('型得你', style: GoogleFonts.notoSerifTc(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        Text('通往心靈嘅經典', style: GoogleFonts.notoSerifTc(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Home Page', style: GoogleFonts.notoSerifTc(fontSize: 18, color: AppColors.textPrimary))),
    );
  }
}
