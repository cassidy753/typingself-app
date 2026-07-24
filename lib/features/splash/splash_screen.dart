import 'dart:math' as math;
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500));
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.5, curve: Curves.easeIn)),
    );
    _logoSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic)),
    );
    _particles = List.generate(typeData.length, (i) {
      final r = math.Random(i);
      return _ParticleState(offsetX: (r.nextDouble() - 0.5) * 80, offsetY: (r.nextDouble() - 0.5) * 60);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 6300), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final profileDone = prefs.getBool('profile_done') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => profileDone ? const _HomePlaceholder() : const GreetingScreen()),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w2 = MediaQuery.of(context).size.width / 2;
    final h2 = MediaQuery.of(context).size.height / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              // Particles — no RepaintBoundary, Positioned direct children of Stack
              ...List.generate(typeData.length, (i) {
                final p = typeData[i];
                final ps = _particles[i];
                final raw = (_progress.value * 1.4 * p.speed).clamp(0.0, 1.0);
                final zPos = p.z - (p.z + 2.0) * raw;
                const persp = 0.08;
                final scale = zPos > 0 ? (1.0 / (1.0 + zPos * persp)) : 0.0;
                final sx = w2 + (p.x * 120 + ps.offsetX) * scale;
                final sy = h2 + (p.y * 80 + ps.offsetY) * scale;
                final alpha = zPos > 0 ? (1.0 - raw * 0.7).clamp(0.0, 1.0) : 0.0;
                if (alpha <= 0 || scale <= 0) return const SizedBox.shrink();
                final ns = p.baseSize * scale;
                return Positioned(
                  left: sx - ns,
                  top: sy - ns * 0.5,
                  child: Opacity(
                    opacity: alpha,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.code, style: TextStyle(fontSize: (p.baseSize * 0.5 * scale).clamp(4, 18), fontWeight: FontWeight.w500, color: p.color.withValues(alpha: 0.5), letterSpacing: 0.08, fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Sans TC', 'sans-serif'])),
                        Text(p.name, style: TextStyle(fontSize: ns.clamp(6, 36), fontWeight: p.weight, color: p.color.withValues(alpha: 0.7), height: 0.9, fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Sans TC', 'sans-serif'])),
                        Text(p.archetype, style: TextStyle(fontSize: (p.baseSize * 0.45 * scale).clamp(3, 14), fontWeight: FontWeight.w300, color: p.color.withValues(alpha: 0.35), fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Sans TC', 'sans-serif'])),
                      ],
                    ),
                  ),
                );
              }),

              // Logo
              Center(
                child: Opacity(
                  opacity: _logoOpacity.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _logoSlide.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 200, height: 200, child: Stack(children: [
                          Positioned(left: 0, right: 0, bottom: 0, child: SizedBox(width: 200, height: 165, child: CustomPaint(painter: const BrainPainter()))),
                          Positioned(left: 0, right: 0, top: 0, child: SizedBox(width: 200, height: 130, child: CustomPaint(painter: const ButterflyPainter()))),
                        ])),
                        const SizedBox(height: 16),
                        Text.rich(TextSpan(children: [
                          TextSpan(text: 'Typingself', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Inter', fontFamilyFallback: ['SF Pro Display', 'sans-serif'])),
                          TextSpan(text: ' | ', style: TextStyle(fontSize: 28, color: AppColors.gold, fontFamily: 'Inter', fontFamilyFallback: ['sans-serif'])),
                          TextSpan(text: '型得你', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'PingFang TC', fontFamilyFallback: ['Noto Serif TC', 'serif'])),
                        ])),
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
