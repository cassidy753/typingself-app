// ═══════════════════════════════════════════════════════════════════════
// AssessmentQuestionScreen — Multi-Select Checkbox Cards
// Each option is a tap-to-toggle checkbox card with pre-set weight (no sliders).
// Daebi palette · Adaptive path · Animated transitions · HK Cantonese
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

  /// Indices of selected options (multi-select via checkboxes)
  final Set<int> _selectedIndices = {};

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
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _submitAnswer() {
    if (_selectedIndices.isEmpty || _answered) return;
    setState(() => _answered = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.engine.submitAnswer(_selectedIndices.toList());

      if (!widget.engine.hasMoreQuestions) {
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
        _selectedIndices.clear();
      });
      _slideCtrl.reset();
      _slideCtrl.forward();
    });
  }

  void _goBack() {
    final success = widget.engine.goBack();
    if (!success) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _currentQuestion = widget.engine.getCurrentQuestion();
      _answered = false;
      _selectedIndices.clear();
    });
    _slideCtrl.reset();
    _slideCtrl.forward();
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
                  Text('$done/$totalEst',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Question body (animated) ───
            Expanded(
              child: SlideTransition(
                position: _slideIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          _currentQuestion.text,
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Options — tap-to-toggle checkboxes (multi-select)
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _currentQuestion.options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final opt = _currentQuestion.options[i];
                            final isSelected = _selectedIndices.contains(i);

                            return GestureDetector(
                              onTap: _answered
                                  ? null
                                  : () => _selectOption(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.cta.withValues(alpha: 0.06)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.cta.withValues(alpha: 0.5)
                                        : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      // Checkbox indicator (square, not circle)
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: isSelected
                                              ? AppColors.cta
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.cta
                                                : AppColors.textMuted,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check,
                                                size: 16, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      // Option text (no weight badge)
                                      Expanded(
                                        child: Text(
                                          opt.text,
                                          style: GoogleFonts.notoSansTc(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
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

            // ─── Bottom: Submit + Hint ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _answered || _selectedIndices.isEmpty
                          ? null
                          : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cta,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.disabled,
                        disabledForegroundColor: AppColors.disabledText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: GoogleFonts.notoSansTc(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(_selectedIndices.isNotEmpty
                          ? '確認答案（${_selectedIndices.length}項）'
                          : '撳選項以繼續'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '可以揀多個答案 · 揀咗可以再轉',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(AssessmentPhase phase) {
    switch (phase) {
      case AssessmentPhase.questions:
        return '🧩 人格分析';
      case AssessmentPhase.result:
        return '✅ 完成';
    }
  }
}
