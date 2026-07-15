// ═══════════════════════════════════════════════════════════════════════
// AssessmentQuestionScreen — Dynamic question display with adaptive path
// Shows progress bar, back button, phase indicator, animated transitions
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'decision_tree_engine.dart';
import 'assessment_result_screen.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  final DecisionTreeEngine engine;
  final void Function(String mbti, String ennea) onComplete;

  const AssessmentQuestionScreen({
    super.key,
    required this.engine,
    required this.onComplete,
  });

  @override
  State<AssessmentQuestionScreen> createState() => _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;
  late Question _currentQuestion;
  bool _answered = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.03, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _currentQuestion = widget.engine.getCurrentQuestion();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = index;
    });

    // Brief delay before moving to next question
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.engine.submitAnswer(index);

      if (!widget.engine.hasMoreQuestions ||
          widget.engine.state.phase == AssessmentPhase.result) {
        // Assessment complete
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AssessmentResultScreen(
              mbti: widget.engine.state.mbtiString,
              ennea: widget.engine.state.enneagramKey,
              engine: widget.engine,
              onComplete: widget.onComplete,
            ),
          ),
        );
        return;
      }

      // Load next question with animation
      setState(() {
        _currentQuestion = widget.engine.getCurrentQuestion();
        _answered = false;
        _selectedOption = null;
      });
      _slideCtrl.reset();
      _slideCtrl.forward();
    });
  }

  void _goBack() {
    if (widget.engine.answeredCount <= 1) {
      Navigator.of(context).pop();
      return;
    }
    // Simple back: just go back if they're early in the flow
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalEst = widget.engine.totalEstimatedQuestions;
    final done = widget.engine.answeredCount;
    final progress = (done / totalEst).clamp(0.0, 1.0);
    final phaseLabel = _phaseLabel(widget.engine.state.phase);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header: Back + Progress ───
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: Icon(Icons.arrow_back_rounded,
                      color: AppColors.textSecondary, size: 24),
                    splashRadius: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phase label
                        Text(phaseLabel,
                          style: GoogleFonts.notoSansTc(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cta,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cta,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${done}/$totalEst',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ─── Question body (animated) ───
            Expanded(
              child: SlideTransition(
                position: _slideIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          _currentQuestion.text,
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Answer options
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _currentQuestion.options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final opt = _currentQuestion.options[i];
                            final isSelected = _selectedOption == i;
                            final showResult = _answered && isSelected;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: _answered ? null :
                                      () => _selectOption(i),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                    backgroundColor: showResult
                                        ? AppColors.cta.withValues(alpha: 0.12)
                                        : AppColors.surface,
                                    foregroundColor: showResult
                                        ? AppColors.cta
                                        : AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: showResult
                                            ? AppColors.cta
                                            : _answered
                                                ? AppColors.border.withValues(
                                                    alpha: 0.5)
                                                : AppColors.border,
                                        width: showResult ? 2 : 1,
                                      ),
                                    ),
                                    textStyle: GoogleFonts.notoSansTc(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Check circle
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.cta
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.cta
                                                : AppColors.textMuted,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check,
                                                size: 14, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(opt.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Bottom hint ───
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                '揀一個最接近你嘅答案',
                style: GoogleFonts.notoSansTc(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(AssessmentPhase phase) {
    switch (phase) {
      case AssessmentPhase.mbti:
        return '🧩 MBTI 分析';
      case AssessmentPhase.mbtiVerification:
        return '✅ MBTI 確認';
      case AssessmentPhase.enneagram:
        return '🎭 九型人格分析';
      case AssessmentPhase.enneagramVerification:
        return '✅ 九型確認';
      default:
        return '';
    }
  }
}
