// ═══════════════════════════════════════════════════════════════════════
// AssessmentIntroScreen — 選擇版本頁 (20/30/45 Q)
// 三個版本選擇卡 · 準確度提示 · Daebi Earthy Palette
// ═══════════════════════════════════════════════════════════════════════

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
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _startAssessment(int questionCount) {
    // Re-create engine with the chosen question count
    final fresh = DecisionTreeEngine(questionCount: questionCount);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // ─── Emoji icon ───
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text('🧠🦋', style: TextStyle(fontSize: 38)),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Title ───
                Text(
                  '了解你嘅 MBTI × 九型人格',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // ─── Subtitle ───
                Text(
                  '揀一個版本，開始你嘅自我認識之旅',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ─── Version cards ───
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: AssessmentVersions.all.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final v = AssessmentVersions.all[i];
                      return _VersionCard(
                        emoji: v.emoji,
                        label: v.label,
                        questionCount: v.questionCount,
                        accuracy: v.accuracy,
                        time: v.time,
                        onTap: () => _startAssessment(v.questionCount),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Trust footer ───
                Text(
                  '「了解自己，贏返自己」',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── VERSION CARD ───
class _VersionCard extends StatelessWidget {
  final String emoji, label, accuracy, time;
  final int questionCount;
  final VoidCallback onTap;

  const _VersionCard({
    required this.emoji,
    required this.label,
    required this.questionCount,
    required this.accuracy,
    required this.time,
    required this.onTap,
  });

  Color get _accentColor {
    if (label == '快測') return AppColors.sage;
    if (label == '標準') return AppColors.mustard;
    return AppColors.cta; // 深度
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            // ── Emoji icon ──
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),

            // ── Middle content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row: label + question count badge
                  Row(
                    children: [
                      Text(label,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${questionCount}題',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Accuracy badge
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 12,
                          color: AppColors.cta),
                      const SizedBox(width: 4),
                      Text(accuracy,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Arrow ──
            Icon(Icons.arrow_forward_rounded,
              size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
