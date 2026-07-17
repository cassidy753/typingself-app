// ═══════════════════════════════════════════════════════════════════════
// AssessmentQuestionScreen — Multi-Select Checkbox Cards
// Each option is a tap-to-toggle checkbox card with pre-set weight (no sliders).
// Daebi palette · Adaptive path · Animated transitions · HK Cantonese
// Edition 2: Smooth slide+fade transitions with staggered option animations.
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
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen>
    with TickerProviderStateMixin {
  // ── Animation Driver ──
  /// Single controller drives both the card and staggered options.
  late final AnimationController _animCtrl;

  // CurvedAnimation children (disposed & recreated when question changes).
  late CurvedAnimation _cardSlideCurve;
  late CurvedAnimation _cardFadeCurve;
  List<CurvedAnimation> _optionCurves = [];

  static final _slideTween = Tween<Offset>(
    begin: const Offset(1.0, 0),
    end: Offset.zero,
  );
  static final _fadeTween = Tween<double>(begin: 0.0, end: 1.0);

  // ── Question State ──
  late Question _currentQuestion;
  bool _answered = false;
  final Set<int> _selectedIndices = {};

  // ── Lifecycle ──

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _currentQuestion = widget.engine.getCurrentQuestion();
    _rebuildAnimations();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _disposeAnimations();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Animation Helpers ──

  void _disposeAnimations() {
    _cardSlideCurve.dispose();
    _cardFadeCurve.dispose();
    for (final c in _optionCurves) {
      c.dispose();
    }
    _optionCurves = [];
  }

  void _rebuildAnimations() {
    final n = _currentQuestion.options.length;

    _cardSlideCurve = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );

    _cardFadeCurve = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    // Stagger options across the 0.30–0.90 range so each one slides & fades
    // in after the card, with even spacing.
    _optionCurves = List.generate(n, (i) {
      final t = n > 1 ? i / (n - 1) : 0.0;
      final start = 0.30 + t * 0.50;
      final end = (start + 0.12).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _animCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
  }

  /// Transition to a new question, rebuilding animations for the new option
  /// count and replaying the entrance.
  void _transitionToNextQuestion() {
    setState(() {
      _currentQuestion = widget.engine.getCurrentQuestion();
      _answered = false;
      _selectedIndices.clear();
    });
    _disposeAnimations();
    _rebuildAnimations();
    _animCtrl.reset();
    _animCtrl.forward();
  }

  // ── Interaction ──

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
      if (!mounted) return;
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

      _transitionToNextQuestion();
    });
  }

  void _goBack() {
    final success = widget.engine.goBack();
    if (!success) {
      Navigator.of(context).pop();
      return;
    }
    _transitionToNextQuestion();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final totalEst = widget.engine.totalEstimatedQuestions;
    final done = widget.engine.answeredCount;
    final progress = (done / totalEst).clamp(0.0, 1.0);
    final phaseLabel = _phaseLabel(widget.engine.state.phase);
    final n = _currentQuestion.options.length;

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
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textSecondary, size: 24),
                    splashRadius: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(phaseLabel,
                          style: GoogleFonts.notoSansTc(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cta,
                          ),
                        ),
                        const SizedBox(height: 4),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text card — slides in from right + fades
                    SlideTransition(
                      position: _slideTween.animate(_cardSlideCurve),
                      child: FadeTransition(
                        opacity: _fadeTween.animate(_cardFadeCurve),
                        child: Container(
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
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Options — tap-to-toggle checkboxes (multi-select)
                    // Each option has a staggered slide+fade entrance.
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: n,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final opt = _currentQuestion.options[i];
                          final isSelected = _selectedIndices.contains(i);

                          return SlideTransition(
                            position: _slideTween.animate(_optionCurves[i]),
                            child: FadeTransition(
                              opacity: _fadeTween.animate(_optionCurves[i]),
                              child: GestureDetector(
                                onTap: _answered
                                    ? null
                                    : () => _selectOption(i),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 250),
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
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                                  size: 16,
                                                  color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
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
