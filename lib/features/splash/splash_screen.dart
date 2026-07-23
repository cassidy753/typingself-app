import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../onboarding/greeting_screen.dart';

const _types = [
  'INTJ', 'INTP', 'ENTJ', 'ENTP',
  'INFJ', 'INFP', 'ENFJ', 'ENFP',
  'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
  'ISTP', 'ISFP', 'ESTP', 'ESFP',
  '1w9', '2w1', '2w3', '3w2',
  '3w4', '4w3', '4w5', '5w4',
  '5w6', '6w5', '6w7', '7w6',
  '7w8', '8w7', '8w9', '9w8',
  '9w1', '1w2',
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _typesScale;
  late final Animation<double> _typesFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // Phase 1: Types fly past (0%–55%)
    _typesScale = Tween<double>(begin: 1.8, end: 0.3).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)),
    );
    _typesFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.55, curve: Curves.easeOut)),
    );

    // Phase 2: Logo appears (50%–85%)
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.8, curve: Curves.easeIn)),
    );
    _logoSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic)),
    );

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3800), _navigateAfterSplash);
  }

  Future<void> _navigateAfterSplash() async {
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
        builder: (context, child) {
          return Stack(
            children: [
              // Cloud of MBTI types
              ...List.generate(_types.length, (i) {
                final row = (i % 6) - 3;
                final col = (i ~/ 6) - 3;
                final random = math.Random(i * 7 + 3);
                final xOffset = random.nextDouble() * 200 - 100;
                final yOffset = random.nextDouble() * 300 - 150;
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + row * 80 + xOffset - 30,
                  top: MediaQuery.of(context).size.height / 2 + col * 70 + yOffset - 20,
                  child: Opacity(
                    opacity: _typesFade.value,
                    child: Transform.scale(
                      scale: _typesScale.value,
                      child: Text(_types[i],
                        style: GoogleFonts.notoSansTc(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // TS Logo
              Center(
                child: Opacity(
                  opacity: _logoFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoSlide.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Seal stamp
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text('型', style: GoogleFonts.notoSerifTc(
                              fontSize: 32, fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            )),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('型得你',
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 32, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('通往心靈嘅經典',
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
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
      body: Center(
        child: Text('Home Page', style: GoogleFonts.notoSerifTc(fontSize: 18, color: AppColors.textPrimary)),
      ),
    );
  }
}
