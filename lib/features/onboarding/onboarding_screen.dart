// ═══════════════════════════════════════════════════════════════════════
// OnboardingScreen — Edition 2 Redesign
// 3-step swipeable PageView: Welcome → Version Selection → Ready
// Glassmorphism cards · Gradient bg (lavender→coral) · Daebi palette · HK Cantonese
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

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageCtrl;
  int _currentPage = 0;
  bool _skipLocked = false;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
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
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
        ),
      ),
    );
  }

  void _goToPage(int page) {
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // ─── Subtle radial glow ───
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _OnboardingRadialGlowPainter(),
                  ),
                ),
              ),

              // ─── Top bar: skip / back + dots ───
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: () => _goToPage(_currentPage - 1),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      const Spacer(),
                      // ── Step dots ──
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? AppColors.purple
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                      ),
                      const Spacer(),
                      // ── Skip / Next ──
                      if (_currentPage < 2)
                        GestureDetector(
                          onTap: _currentPage == 0
                              ? _onSkip
                              : () => _goToPage(_currentPage + 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _currentPage == 0 ? '跳過' : '下一步',
                              style: GoogleFonts.notoSansTc(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                    ],
                  ),
                ),
              ),

              // ─── PageView ───
              Positioned.fill(
                top: 56,
                child: PageView(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _WelcomeStep(onSkip: _onSkip),
                    _VersionStep(onSelect: _onSelectVersion),
                    _ReadyStep(onStart: _onSkip, onSelect: _onSelectVersion),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Step 1: Welcome
// ═══════════════════════════════════════════════════════════════════════

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onSkip;
  const _WelcomeStep({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // ── Emoji icon ──
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B72AA), Color(0xFFE0785A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🧠', style: TextStyle(fontSize: 44)),
              ),
            ),
          ),
          const SizedBox(height: 28),
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
              '歡迎你嚟到\nTypingself！',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifTc(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.3,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
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
              '了解自己，係成長嘅第一步。\n由人格類型開始，發掘你最真實嘅一面。',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTc(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(flex: 1),
          // ── Bottom CTA ──
          GestureDetector(
            onTap: onSkip,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                '了解型得你 🫵',
                style: GoogleFonts.notoSansTc(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.purple.withValues(alpha: 0.4),
                  decorationThickness: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Step 2: Version Selection
// ═══════════════════════════════════════════════════════════════════════

class _VersionStep extends StatelessWidget {
  final void Function(int index) onSelect;
  const _VersionStep({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const versions = AssessmentVersions.all;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            '揀個版本，開始你嘅\n人格探索之旅',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '三個版本，不同程度的詳細分析',
            style: GoogleFonts.notoSansTc(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          // ── 3 Version Cards ──
          for (int i = 0; i < versions.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i < versions.length - 1 ? 14 : 0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 500 + i * 80),
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
                child: _OnboardingVersionCard(
                  emoji: versions[i].emoji,
                  label: versions[i].label,
                  description: versions[i].description,
                  questionCount: versions[i].questionCount,
                  accuracy: versions[i].accuracy,
                  time: versions[i].time,
                  accentKey: versions[i].label,
                  onTap: () => onSelect(i),
                  showRecommendedBadge: i == 1,
                ),
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Step 3: Ready / Final
// ═══════════════════════════════════════════════════════════════════════

class _ReadyStep extends StatelessWidget {
  final VoidCallback onStart;
  final void Function(int index) onSelect;
  const _ReadyStep({required this.onStart, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // ── Big emoji ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A843), Color(0xFFE0785A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mustard.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🚀', style: TextStyle(fontSize: 52)),
              ),
            ),
          ),
          const SizedBox(height: 32),
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
              '準備好未？',
              style: GoogleFonts.notoSerifTc(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
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
              '你可以隨時跳過測驗，直接探索其他內容。\n或者而家就開始，了解真實嘅自己。',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTc(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(),
          // ── CTA buttons ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
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
            child: Column(
              children: [
                // Quick start
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => onSelect(1), // 標準 version
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                      textStyle: GoogleFonts.notoSansTc(
                        fontSize: 17, fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('開始測驗'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onStart,
                  child: Text(
                    '遲啲先測',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textSecondary.withValues(alpha: 0.4),
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── SUBTLE RADIAL GLOW PAINTER ───
class _OnboardingRadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
class _OnboardingVersionCard extends StatelessWidget {
  final String emoji, label, accuracy, time, description;
  final int questionCount;
  final String accentKey;
  final VoidCallback onTap;
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
    return GestureDetector(
      onTap: onTap,
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
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              // ── Recommended badge ──
              if (showRecommendedBadge)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.35),
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
    );
  }
}
