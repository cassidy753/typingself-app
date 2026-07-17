// ═══════════════════════════════════════════════════════════════════════
// AssessmentQuestionScreen — Multi-Select Checkbox Cards
// Edition 2 redesign: gradient bg, spacious layout, elegant typography
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

  // Question card slides in from right (book/page-turn feel)
  static final _cardSlideTween = Tween<Offset>(
    begin: const Offset(1.0, 0),
    end: Offset.zero,
  );
  // Options slide up from below (staircased entrance)
  static final _optionSlideTween = Tween<Offset>(
    begin: const Offset(0.0, 0.08),
    end: Offset.zero,
  );
  static final _fadeTween = Tween<double>(begin: 0.0, end: 1.0);
  static final _scaleTween = Tween<double>(begin: 0.96, end: 1.0);

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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確認離開？'),
        content: const Text('進度將會保留，你可以隨時返嚟繼續。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('留低'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _doGoBack();
            },
            child: const Text('離開'),
          ),
        ],
      ),
    );
  }

  void _doGoBack() {
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
          child: Column(
            children: [
              // ─── Header: Back + Progress ───
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF8B6F5E), size: 26),
                      splashRadius: 22,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(phaseLabel,
                            style: GoogleFonts.notoSansTc(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cta,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Progress bar with gradient fill
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.border.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.cta,
                                        AppColors.purple.withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Progress counter badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$done/$totalEst',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Question body (animated) ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Question number indicator (prominent) ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '第 ${done + 1} 題 / 共 $totalEst 題',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cta,
                            height: 1.3,
                          ),
                        ),
                      ),
                      // ── Question text card — slides in from right + fades
                      // with a subtle scale entrance for a polished feel ──
                      SlideTransition(
                        position: _cardSlideTween.animate(_cardSlideCurve),
                        child: FadeTransition(
                          opacity: _fadeTween.animate(_cardFadeCurve),
                          child: ScaleTransition(
                            scale: _scaleTween.animate(_cardSlideCurve),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 28,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purple.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _currentQuestion.text,
                                style: GoogleFonts.notoSerifTc(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Options — tap-to-toggle checkboxes (multi-select) ──
                      // Each option has a staggered slide-up + fade entrance.
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: n,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final opt = _currentQuestion.options[i];
                            final isSelected = _selectedIndices.contains(i);

                            return SlideTransition(
                              position:
                                  _optionSlideTween.animate(_optionCurves[i]),
                              child: FadeTransition(
                                opacity:
                                    _fadeTween.animate(_optionCurves[i]),
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
                                          ? AppColors.cta.withValues(alpha: 0.08)
                                          : Colors.white.withValues(alpha: 0.72),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.cta
                                                .withValues(alpha: 0.6)
                                            : AppColors.border
                                                .withValues(alpha: 0.5),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          // ── Checkbox indicator
                                          // (square, not circle — larger for
                                          //  comfortable tap targets)
                                          // Scale bounce on select ──
                                          AnimatedScale(
                                            scale: isSelected ? 1.2 : 1.0,
                                            duration: const Duration(
                                                milliseconds: 350),
                                            curve: Curves.elasticOut,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: isSelected
                                                    ? AppColors.cta
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.cta
                                                      : AppColors.textMuted,
                                                  width: 2.2,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(Icons.check,
                                                      size: 18,
                                                      color: Colors.white)
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              opt.text,
                                              style: GoogleFonts.notoSansTc(
                                                fontSize: 17,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                                height: 1.5,
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                          disabledBackgroundColor:
                              AppColors.disabled.withValues(alpha: 0.6),
                          disabledForegroundColor: AppColors.disabledText,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: GoogleFonts.notoSansTc(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          elevation: 0,
                        ),
                        child: Text(_selectedIndices.isNotEmpty
                            ? '確認答案（${_selectedIndices.length}項）'
                            : '撳選項以繼續'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '可以揀多個答案 · 揀咗可以再轉',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
