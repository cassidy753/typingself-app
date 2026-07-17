// ═══════════════════════════════════════════════════════════════════════
// AssessmentIntroScreen — Edition 2
// 3 glassmorphism version cards (20/30/45Q) shown all at once · No scroll
// Modern card UI · Accuracy badges · Selection bounce · Daebi palette
// HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'decision_tree_engine.dart';
import 'assessment_question_screen.dart';

class AssessmentIntroScreen extends StatefulWidget {
  final DecisionTreeEngine engine;
  final void Function(String mbti, String ennea) onComplete;

  const AssessmentIntroScreen({
    super.key,
    required this.engine,
    required this.onComplete,
  });

  @override
  State<AssessmentIntroScreen> createState() => _AssessmentIntroScreenState();
}

class _AssessmentIntroScreenState extends State<AssessmentIntroScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // Default: 標準 (index 1)
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _startAssessment() {
    final version = AssessmentVersions.all[_selectedIndex];
    final fresh = DecisionTreeEngine(questionCount: version.questionCount);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AssessmentQuestionScreen(
          engine: fresh,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const versions = AssessmentVersions.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Subtle radial gradient backdrop for glassmorphism ───
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _RadialGlowPainter(),
                ),
              ),
            ),

            // ─── Content ───
            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // ─── Title ───
                      Text(
                        '揀個版本，開始了解自己',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerifTc(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '三個選項 — 快、平衡、深入，任你揀',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ─── 3 Version Cards (no scroll — fixed layout) ───
                      for (int i = 0; i < versions.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i < versions.length - 1 ? 10 : 0,
                          ),
                          child: _VersionCard(
                            emoji: versions[i].emoji,
                            label: versions[i].label,
                            questionCount: versions[i].questionCount,
                            accuracy: versions[i].accuracy,
                            time: versions[i].time,
                            accentKey: versions[i].label,
                            isSelected: _selectedIndex == i,
                            onTap: () =>
                                setState(() => _selectedIndex = i),
                            entranceDelay: i,
                          ),
                        ),

                      const Spacer(),

                      // ─── Trust footer ───
                      Text(
                        '「了解自己，贏返自己」',
                        style: GoogleFonts.notoSerifTc(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── CTA Button ───
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: _startAssessment,
                          child: Text(
                            '開始 ${versions[_selectedIndex].label}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUBTLE RADIAL GLOW PAINTER ───
// Provides a faint gradient behind the cards so the glassmorphism
// BackdropFilter has something to blur.
class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm amber glow near the cards
    const warmColor = Color(0xFFE8B87A);
    final gradient = RadialGradient(
      center: const Alignment(0, -0.15),
      radius: 0.7,
      colors: [
        warmColor.withValues(alpha: 0.12),
        warmColor.withValues(alpha: 0.04),
        warmColor.withValues(alpha: 0.0),
      ],
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.45),
          width: size.width * 1.4,
          height: size.height * 0.9,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint);

    // Faint coral tint from top-right
    final coralGradient = RadialGradient(
      center: const Alignment(0.7, -0.8),
      radius: 0.9,
      colors: [
        AppColors.cta.withValues(alpha: 0.05),
        AppColors.cta.withValues(alpha: 0.0),
      ],
    );
    final paint2 = Paint()
      ..shader = coralGradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── GLASSMORPHISM VERSION CARD ───
class _VersionCard extends StatelessWidget {
  final String emoji, label, accuracy, time;
  final int questionCount;
  final String accentKey;
  final bool isSelected;
  final VoidCallback onTap;
  final int entranceDelay;

  const _VersionCard({
    required this.emoji,
    required this.label,
    required this.questionCount,
    required this.accuracy,
    required this.time,
    required this.accentKey,
    required this.isSelected,
    required this.onTap,
    required this.entranceDelay,
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
          scale: isSelected ? 1.0 : 0.975,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _accentColor.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // ── Glassmorphism backdrop blur (selected only) ──
                  if (isSelected)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(color: Colors.transparent),
                      ),
                    ),

                  // ── Frosted glass surface ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _accentColor.withValues(alpha: 0.07),
                                AppColors.surface.withValues(alpha: 0.10),
                                _accentColor.withValues(alpha: 0.03),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surface.withValues(alpha: 0.92),
                                AppColors.surface.withValues(alpha: 0.85),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _accentColor.withValues(alpha: 0.50)
                            : AppColors.border.withValues(alpha: 0.55),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // ── Icon container (left) ──
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _accentColor.withValues(alpha: 0.20)
                                : _accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ── Center: title + subtitle ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    label,
                                    style: GoogleFonts.notoSansTc(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '($questionCount題)',
                                    style: GoogleFonts.notoSansTc(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _subtitle,
                                style: GoogleFonts.notoSansTc(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Accuracy badge (right) ──
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isSelected ? 1.0 : 0.6,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _accentColor.withValues(alpha: 0.20)
                                  : AppColors.divider.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _badgeText,
                              style: GoogleFonts.notoSansTc(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? _accentColor
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
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
