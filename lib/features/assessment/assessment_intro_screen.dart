// ═══════════════════════════════════════════════════════════════════════
// AssessmentIntroScreen — 簡介頁 (Estimated time + what to expect)
// Daebi Earthy Palette · Warm Sand · Muted Coral · Dark Brown
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
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ─── Emoji icon ───
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.cta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text('🧠', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 28),

                // ─── Title ───
                Text(
                  '了解你嘅 MBTI × 九型人格',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // ─── Subtitle ───
                Text(
                  '一條龍幫你搵出你專屬嘅人格組合名',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // ─── Info cards ───
                _infoRow('⏱️', '約 3-5 分鐘', '12-20 條問題，跟住你嘅答案動態調整'),
                const SizedBox(height: 12),
                _infoRow('🧩', 'MBTI + 九型人格', '雙層分析，比普通測試更深入'),
                const SizedBox(height: 12),
                _infoRow('🎭', '專屬人格名', '獲得你嘅地道廣東話人格稱號'),
                const SizedBox(height: 12),
                _infoRow('🔒', '100% 本地處理', '你嘅答案唔會上傳，安心作答'),
                const SizedBox(height: 40),

                // ─── Start button ───
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _startAssessment,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: GoogleFonts.notoSansTc(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('開始了解自己'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

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

  Widget _infoRow(String emoji, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startAssessment() {
    widget.engine.reset();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssessmentQuestionScreen(
          engine: widget.engine,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }
}
