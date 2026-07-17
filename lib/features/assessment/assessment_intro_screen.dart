// ═══════════════════════════════════════════════════════════════════════
// AssessmentIntroScreen — Edition 2 Redesign
// Gradient background (lavender→coral), spacious layout, large typography
// 3 glassmorphism version cards (20/30/45Q) · Noto Serif TC titles
// Daebi palette · HK Cantonese
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
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // ─── Title (Noto Serif TC, spacious) ───
                        Text(
                          '揀個版本，開始了解自己',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.3,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '三個選項 — 快、平衡、深入，任你揀',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansTc(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ─── 3 Version Cards (spacious spacing) ───
                        for (int i = 0; i < versions.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i < versions.length - 1 ? 14 : 0,
                            ),
                            child: _VersionCard(
                              emoji: versions[i].emoji,
                              label: versions[i].label,
                              questionCount: versions[i].questionCount,
                              accuracy: versions[i].accuracy,
                              time: versions[i].time,
                              accentKey: versions[i].label,
                              isSelected: _selectedIndex == i,
                              onTap: () => setState(() => _selectedIndex = i),
                              entranceDelay: i,
                            ),
                          ),

                        const Spacer(),

                        // ─── Tagline ───
                        Text(
                          '「了解自己，贏返自己」',
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ─── CTA Button ───
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: _startAssessment,
                            style: FilledButton.styleFrom(
                              textStyle: GoogleFonts.notoSansTc(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(
                              '開始 ${versions[_selectedIndex].label}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
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

// ─── SUBTLE RADIAL GLOW PAINTER ───
// Provides a faint gradient behind the cards so the glassmorphism
// BackdropFilter has something to blur.
class _RadialGlowPainter extends CustomPainter {
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
          center: Offset(size.width / 2, size.height * 0.40),
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
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _accentColor.withValues(alpha: 0.20),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // ── Glassmorphism backdrop blur ──
                  if (isSelected)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(color: Colors.transparent),
                      ),
                    ),

                  // ── Frosted glass surface (more spacious padding) ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _accentColor.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.15),
                                _accentColor.withValues(alpha: 0.04),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.88),
                                Colors.white.withValues(alpha: 0.78),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? _accentColor.withValues(alpha: 0.55)
                            : Colors.white.withValues(alpha: 0.70),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // ── Emoji icon container (left, larger) ──
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _accentColor.withValues(alpha: 0.20)
                                : _accentColor.withValues(alpha: 0.08),
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

                        // ── Accuracy badge (right, larger) ──
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isSelected ? 1.0 : 0.6,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _accentColor.withValues(alpha: 0.20)
                                  : AppColors.divider.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _badgeText,
                              style: GoogleFonts.notoSansTc(
                                fontSize: 17,
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
