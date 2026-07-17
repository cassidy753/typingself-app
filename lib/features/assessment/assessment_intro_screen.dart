// ═══════════════════════════════════════════════════════════════════════
// AssessmentIntroScreen — 選擇版本頁 (20/30/45 Q)
// 三個版本選擇卡 · 準確度提示 · Daebi Earthy Palette
// Modern card UI (plan selection style)
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
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
                    '選擇評估方式',
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
                    '揀一個最適合你嘅版本',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Version cards ───
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (int i = 0; i < AssessmentVersions.all.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i < AssessmentVersions.all.length - 1 ? 12 : 0,
                            ),
                            child: _PlanCard(
                              emoji: AssessmentVersions.all[i].emoji,
                              label: AssessmentVersions.all[i].label,
                              questionCount: AssessmentVersions.all[i].questionCount,
                              accuracy: AssessmentVersions.all[i].accuracy,
                              time: AssessmentVersions.all[i].time,
                              isSelected: _selectedIndex == i,
                              onTap: () => setState(() => _selectedIndex = i),
                            ),
                          ),
                      ],
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
                  const SizedBox(height: 16),

                  // ─── CTA Button ───
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _startAssessment,
                      child: const Text('開始評估'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PLAN CARD ───
class _PlanCard extends StatelessWidget {
  final String emoji, label, accuracy, time;
  final int questionCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.emoji,
    required this.label,
    required this.questionCount,
    required this.accuracy,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accentColor {
    if (label == '快測') return AppColors.sage;
    if (label == '標準') return AppColors.mustard;
    return AppColors.cta; // 深度
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _accentColor : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // ── Emoji icon container (left) ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? _accentColor.withValues(alpha: 0.15)
                    : _accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),

            // ── Center content: title + subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
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
                  const SizedBox(height: 3),
                  Text(_subtitle,
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
              duration: const Duration(milliseconds: 350),
              opacity: isSelected ? 1.0 : 0.65,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accentColor.withValues(alpha: 0.15)
                      : AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _badgeText,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? _accentColor : AppColors.textMuted,
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
