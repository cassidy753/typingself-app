import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../onboarding/onboarding_screen.dart';

// ──────────────────────────────────────────────
// SPLASH SCREEN — animated brain+butterfly logo
// Checks onboarding_done to skip → home if seen
// ──────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _brainFade;
  late final Animation<double> _brainScale;
  late final Animation<double> _butterflyFade;
  late final Animation<Offset> _butterflySlide;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Brain: 0→30% (0–720ms) — fade in + scale up
    _brainFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _brainScale = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // Butterfly: 25%→60% (600–1440ms) — slide up from brain + fade in
    _butterflyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _butterflySlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Text: 50%→85% (1200–2040ms) — fade in
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();

    // Auto‑navigate after animation finishes
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _navigateAfterSplash();
    });
  }

  Future<void> _navigateAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    if (onboardingDone) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Purple → pink/warm gradient (Daebi palette)
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBE0F5), // light purple
              Color(0xFFF5EDE0), // warm sand
              Color(0xFFFCE8E0), // light coral
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // ── Brain + Butterfly logo ──
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Brain
                      Opacity(
                        opacity: _brainFade.value,
                        child: Transform.scale(
                          scale: _brainScale.value,
                          child: const CustomPaint(
                            size: Size(140, 120),
                            painter: _BrainPainter(),
                          ),
                        ),
                      ),
                      // Butterfly (emerges from brain)
                      Positioned(
                        top: 30 + _butterflySlide.value.dy * 50,
                        child: Opacity(
                          opacity: _butterflyFade.value,
                          child: const CustomPaint(
                            size: Size(180, 120),
                            painter: _ButterflyPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ── Tagline ──
                Opacity(
                  opacity: _textFade.value,
                  child: Column(
                    children: [
                      Text(
                        'Typingself',
                        style: GoogleFonts.notoSerifTc(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '型得你・人格成長',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // ── Footer ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.purple.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CUSTOM PAINTERS — abstract brain + butterfly
// ──────────────────────────────────────────────

class _BrainPainter extends CustomPainter {
  const _BrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final hw = size.width * 0.38; // half-width of each hemisphere
    final hh = size.height * 0.38;

    // ── Left hemisphere ──
    final leftPath = Path()
      ..moveTo(cx, cy - hh * 0.2)
      ..cubicTo(
        cx - hw * 0.2, cy - hh * 1.2,  // control 1
        cx - hw * 1.3, cy - hh * 0.4,  // control 2
        cx - hw * 0.9, cy + hh * 0.3,  // end
      )
      ..cubicTo(
        cx - hw * 0.7, cy + hh * 0.7,
        cx - hw * 0.1, cy + hh * 0.5,
        cx, cy + hh * 0.1,
      )
      ..close();
    canvas.drawPath(leftPath, paint);

    // ── Right hemisphere ──
    final rightPath = Path()
      ..moveTo(cx, cy - hh * 0.2)
      ..cubicTo(
        cx + hw * 0.2, cy - hh * 1.2,
        cx + hw * 1.3, cy - hh * 0.4,
        cx + hw * 0.9, cy + hh * 0.3,
      )
      ..cubicTo(
        cx + hw * 0.7, cy + hh * 0.7,
        cx + hw * 0.1, cy + hh * 0.5,
        cx, cy + hh * 0.1,
      )
      ..close();
    canvas.drawPath(rightPath, paint);

    // ── Central fissure line ──
    final linePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(cx, cy - hh * 0.8),
      Offset(cx, cy + hh * 0.3),
      linePaint,
    );

    // ── Gyri / fold lines ──
    final foldPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Left folds
    for (final y in [-0.3, 0.0, 0.25]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - hw * 0.45, cy + y * hh), width: hw * 0.6, height: hh * 0.3),
        math.pi * 0.2,
        math.pi * 0.6,
        false,
        foldPaint,
      );
    }
    // Right folds
    for (final y in [-0.3, 0.0, 0.25]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + hw * 0.45, cy + y * hh), width: hw * 0.6, height: hh * 0.3),
        math.pi * 1.2,
        math.pi * 0.6,
        false,
        foldPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ButterflyPainter extends CustomPainter {
  const _ButterflyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;
    final sw = size.width * 0.3; // wing span factor

    // ── Left upper wing ──
    final paint = Paint()
      ..color = AppColors.cta.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    final leftWing = Path()
      ..moveTo(cx, cy)
      ..cubicTo(
        cx - sw * 0.05, cy - sw * 0.9,
        cx - sw * 1.1, cy - sw * 0.6,
        cx - sw * 0.8, cy + sw * 0.1,
      )
      ..cubicTo(
        cx - sw * 0.6, cy + sw * 0.3,
        cx - sw * 0.15, cy + sw * 0.1,
        cx, cy,
      )
      ..close();
    canvas.drawPath(leftWing, paint);

    // ── Right upper wing ──
    final rightWing = Path()
      ..moveTo(cx, cy)
      ..cubicTo(
        cx + sw * 0.05, cy - sw * 0.9,
        cx + sw * 1.1, cy - sw * 0.6,
        cx + sw * 0.8, cy + sw * 0.1,
      )
      ..cubicTo(
        cx + sw * 0.6, cy + sw * 0.3,
        cx + sw * 0.15, cy + sw * 0.1,
        cx, cy,
      )
      ..close();
    canvas.drawPath(rightWing, paint);

    // ── Left lower wing ──
    paint.color = AppColors.purple.withValues(alpha: 0.5);
    final leftLower = Path()
      ..moveTo(cx - sw * 0.1, cy + sw * 0.05)
      ..cubicTo(
        cx - sw * 0.3, cy + sw * 0.1,
        cx - sw * 0.6, cy + sw * 0.5,
        cx - sw * 0.25, cy + sw * 0.6,
      )
      ..cubicTo(
        cx - sw * 0.1, cy + sw * 0.65,
        cx, cy + sw * 0.1,
        cx - sw * 0.1, cy + sw * 0.05,
      )
      ..close();
    canvas.drawPath(leftLower, paint);

    // ── Right lower wing ──
    final rightLower = Path()
      ..moveTo(cx + sw * 0.1, cy + sw * 0.05)
      ..cubicTo(
        cx + sw * 0.3, cy + sw * 0.1,
        cx + sw * 0.6, cy + sw * 0.5,
        cx + sw * 0.25, cy + sw * 0.6,
      )
      ..cubicTo(
        cx + sw * 0.1, cy + sw * 0.65,
        cx, cy + sw * 0.1,
        cx + sw * 0.1, cy + sw * 0.05,
      )
      ..close();
    canvas.drawPath(rightLower, paint);

    // ── Body ──
    final bodyPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final bodyPath = Path()
      ..moveTo(cx, cy + sw * 0.6)
      ..lineTo(cx, cy - sw * 0.1);
    canvas.drawPath(bodyPath, bodyPaint);

    // ── Antennae ──
    final antennaPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    // Left antenna
    final leftAntenna = Path()
      ..moveTo(cx, cy - sw * 0.1)
      ..cubicTo(
        cx - sw * 0.15, cy - sw * 0.3,
        cx - sw * 0.25, cy - sw * 0.45,
        cx - sw * 0.3, cy - sw * 0.5,
      );
    canvas.drawPath(leftAntenna, antennaPaint);
    // Right antenna
    final rightAntenna = Path()
      ..moveTo(cx, cy - sw * 0.1)
      ..cubicTo(
        cx + sw * 0.15, cy - sw * 0.3,
        cx + sw * 0.25, cy - sw * 0.45,
        cx + sw * 0.3, cy - sw * 0.5,
      );
    canvas.drawPath(rightAntenna, antennaPaint);

    // ── Wing vein details ──
    final veinPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    // Left wing veins
    for (final angle in [0.2, 0.4, 0.6]) {
      final vx = cx - sw * 0.7 * angle;
      final vy = cy - sw * 0.7 * (1 - angle);
      canvas.drawLine(Offset(cx, cy), Offset(vx, vy), veinPaint);
    }
    // Right wing veins
    for (final angle in [0.2, 0.4, 0.6]) {
      final vx = cx + sw * 0.7 * angle;
      final vy = cy - sw * 0.7 * (1 - angle);
      canvas.drawLine(Offset(cx, cy), Offset(vx, vy), veinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
