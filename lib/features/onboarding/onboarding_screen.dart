// ═══════════════════════════════════════════════════════════════════════
// OnboardingScreen — Edition 2
// Shows after splash for first-time users before entering the app
// Welcome message/animation + 3 glassmorphism version cards + skip btn
// Gradient bg (lavender→coral) · Daebi palette · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/decision_tree_engine.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  bool _skipLocked = false; // prevent double-tap during navigation

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onSkip() {
    if (_skipLocked) return;
    _skipLocked = true;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _onSelectVersion(int index) {
    if (_skipLocked) return;
    _skipLocked = true;

    final version = AssessmentVersions.all[index];
    final fresh = DecisionTreeEngine(questionCount: version.questionCount);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssessmentIntroScreen(
          engine: fresh,
          onComplete: (mbti, ennea) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('mbti', mbti);
              prefs.setString('ennea', ennea);
              prefs.setBool('test_done', true);
            });
            if (mounted) {
              // Pop all assessment screens back to onboarding
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Then go home
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const versions = AssessmentVersions.all;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBE0F5), // light purple / lavender mist
              Color(0xFFFCE8E0), // light coral / warm pink
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ─── Subtle radial glow for glassmorphism depth ───
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _OnboardingRadialGlowPainter(),
                  ),
                ),
              ),

              // ─── Page entrance animation ───
              FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // ─── Welcome Section ───
                        // Welcome emoji icon
                        _AnimatedWelcome(),

                        const SizedBox(height: 32),

                        // ─── 3 Version Cards ───
                        for (int i = 0; i < versions.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i < versions.length - 1 ? 14 : 0,
                            ),
                            child: _OnboardingVersionCard(
                              emoji: versions[i].emoji,
                              label: versions[i].label,
                              description: versions[i].description,
                              questionCount: versions[i].questionCount,
                              accuracy: versions[i].accuracy,
                              time: versions[i].time,
                              accentKey: versions[i].label,
                              onTap: () => _onSelectVersion(i),
                              entranceDelay: i,
                              showRecommendedBadge: i == 1,
                            ),
                          ),

                        const Spacer(),

                        // ─── Skip Button ───
                        GestureDetector(
                          onTap: _onSkip,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: Text(
                              '遲啲先測',
                              style: GoogleFonts.notoSansTc(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    AppColors.textSecondary.withValues(alpha: 0.4),
                                decorationThickness: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WELCOME SECTION ───
// Animated entrance for the welcome icon, title, and subtitle.
// Uses staggered TweenAnimationBuilders for a polished first-impression.
class _AnimatedWelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Emoji icon container ──
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                '🧠',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // ── Title ──
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Text(
            '歡迎你嚟到 Typingself！',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.3,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ── Subtitle ──
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Text(
            '了解自己，係成長嘅第一步。\n揀個版本，開始你嘅人格探索之旅。',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTc(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SUBTLE RADIAL GLOW PAINTER ───
// Provides a faint gradient behind the cards so the glassmorphism
// BackdropFilter has something to blur.
class _OnboardingRadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm lavender glow for glassmorphism depth
    const glowColor = Color(0xFFD4C4E8);
    final gradient = RadialGradient(
      center: const Alignment(0, -0.1),
      radius: 0.65,
      colors: [
        glowColor.withValues(alpha: 0.25),
        glowColor.withValues(alpha: 0.08),
        glowColor.withValues(alpha: 0.0),
      ],
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.38),
          width: size.width * 1.5,
          height: size.height * 0.85,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint);

    // Warm coral tint from bottom-right
    const coralColor = Color(0xFFE8A090);
    final coralGradient = RadialGradient(
      center: const Alignment(0.7, 0.9),
      radius: 0.8,
      colors: [
        coralColor.withValues(alpha: 0.12),
        coralColor.withValues(alpha: 0.0),
      ],
    );
    final paint2 = Paint()
      ..shader = coralGradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint2);

    // Subtle highlight from top-left
    const highlightColor = Color(0xFFFFFAF0);
    final highlightGradient = RadialGradient(
      center: const Alignment(-0.8, -0.8),
      radius: 0.5,
      colors: [
        highlightColor.withValues(alpha: 0.20),
        highlightColor.withValues(alpha: 0.0),
      ],
    );
    final paint3 = Paint()
      ..shader = highlightGradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── ONBOARDING VERSION CARD ───
// Glassmorphism card identical to the one in AssessmentIntroScreen.
// Same design: frosted white bg, accent-colored selection glow,
// emoji icon, label, description, accuracy badge.
// Tapping the card navigates directly (no selection state).
class _OnboardingVersionCard extends StatelessWidget {
  final String emoji, label, accuracy, time, description;
  final int questionCount;
  final String accentKey;
  final VoidCallback onTap;
  final int entranceDelay;
  final bool showRecommendedBadge;

  const _OnboardingVersionCard({
    required this.emoji,
    required this.label,
    required this.description,
    required this.questionCount,
    required this.accuracy,
    required this.time,
    required this.accentKey,
    required this.onTap,
    required this.entranceDelay,
    this.showRecommendedBadge = false,
  });

  Color get _accentColor {
    if (accentKey == '快測') return AppColors.sage;
    if (accentKey == '標準') return AppColors.mustard;
    return AppColors.purple; // 深度
  }

  String get _badgeText {
    final match = RegExp(r'(\d+)%').firstMatch(accuracy);
    return '${match?.group(1) ?? ''}%';
  }

  String get _subtitle => '$accuracy · $time';

  @override
  Widget build(BuildContext context) {
    // Staggered entrance: slide up with opacity, delayed by index
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + entranceDelay * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // ── Glassmorphism backdrop blur ──
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                  // ── Frosted glass surface ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _accentColor.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.15),
                          _accentColor.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _accentColor.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // ── Emoji icon container (left) ──
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ── Center: label + details ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    label,
                                    style: GoogleFonts.notoSansTc(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '($questionCount題)',
                                    style: GoogleFonts.notoSansTc(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: GoogleFonts.notoSansTc(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _subtitle,
                                style: GoogleFonts.notoSansTc(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Accuracy badge (right) ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _badgeText,
                            style: GoogleFonts.notoSansTc(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Recommended badge (top-right overlay) ──
                  if (showRecommendedBadge)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800)
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '⭐ 推薦',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
