import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../onboarding/greeting_screen.dart';
import 'type_data.dart';
import '../../core/brain_butterfly_painter.dart';

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
  late final List<_ParticleState> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 7000));

    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.6, curve: Curves.easeIn)),
    );
    _logoSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic)),
    );

    // Assign each type a random screen starting position
    _particles = List.generate(typeData.length, (i) {
      final r = math.Random(i);
      return _ParticleState(
        offsetX: (r.nextDouble() - 0.5) * 80,
        offsetY: (r.nextDouble() - 0.5) * 60,
      );
    });

    // Small delay for CanvasKit font loading
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 7900), _navigate);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              // Layer 1: Flying type particles
              ...List.generate(typeData.length, (i) {
                final p = typeData[i];
                final ps = _particles[i];

                final rawProgress = _progress.value * 1.4 * p.speed;
                final clamped = rawProgress.clamp(0.0, 1.0);
                final zPos = p.z - (p.z + 2.0) * clamped;
                const persp = 0.08;
                final scale = zPos > 0 ? (1.0 / (1.0 + zPos * persp)) : 0.0;

                final halfW = MediaQuery.of(context).size.width / 2;
                final halfH = MediaQuery.of(context).size.height / 2;
                final screenX = halfW + (p.x * 120 + ps.offsetX) * scale;
                final screenY = halfH + (p.y * 80 + ps.offsetY) * scale;
                final blur = (zPos * 1.8).clamp(0.0, 15.0);
                final alpha = zPos > 0 ? (1.0 - clamped * 0.7).clamp(0.0, 1.0) : 0.0;

                if (alpha <= 0 || scale <= 0) return const SizedBox.shrink();

                final nameSize = p.baseSize * scale;
                final codeSize = (p.baseSize * 0.5) * scale;
                final archetypeSize = (p.baseSize * 0.45) * scale;

                return Positioned(
                  left: screenX - nameSize,
                  top: screenY - nameSize * 0.5,
                  child: Opacity(
                    opacity: alpha,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Code (small, subtle)
                          Text(p.code, style: TextStyle(
                            fontSize: codeSize.clamp(4, 18), fontWeight: FontWeight.w500,
                            color: p.color.withValues(alpha: 0.5),
                            letterSpacing: 0.08,
                            fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Sans TC', 'sans-serif'],
                          )),
                          // Name (large, main)
                          Text(p.name, style: TextStyle(
                            fontSize: nameSize.clamp(6, 36), fontWeight: p.weight,
                            color: p.color.withValues(alpha: 0.7),
                            height: 0.9,
                            fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Sans TC', 'sans-serif'],
                          )),
                          // Archetype (small, italic)
                          Text(p.archetype, style: TextStyle(
                            fontSize: archetypeSize.clamp(3, 14), fontWeight: FontWeight.w300,
                            color: p.color.withValues(alpha: 0.35),
                            fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Sans TC', 'sans-serif'],
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Layer 2: Logo
              Center(
                child: Opacity(
                  opacity: _logoOpacity.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _logoSlide.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brain + Butterfly stacked
                        SizedBox(
                          width: 200, height: 200,
                          child: Stack(
                            children: [
                              Positioned(left: 0, right: 0, bottom: 0,
                                child: SizedBox(width: 200, height: 165,
                                  child: CustomPaint(painter: const BrainPainter()),
                                ),
                              ),
                              Positioned(left: 0, right: 0, top: 0,
                                child: SizedBox(width: 200, height: 130,
                                  child: CustomPaint(painter: const ButterflyPainter()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('型得你', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Serif TC', 'serif'])),
                        const SizedBox(height: 10),
                        Text('通往心靈嘅經典', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Serif TC', 'serif'])),
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

class _ParticleState {
  final double offsetX, offsetY;
  const _ParticleState({required this.offsetX, required this.offsetY});
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
