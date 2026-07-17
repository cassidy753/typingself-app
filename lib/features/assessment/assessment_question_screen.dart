// ═══════════════════════════════════════════════════════════════════════
// AssessmentQuestionScreen — Weighted Multi-Select Question Display
// Each option has a checkbox to toggle + intensity slider (1–10).
// Daebi palette · Adaptive path · Animated transitions
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

  /// optionIndex → intensity (1.0–10.0)
  final Map<int, double> _selections = {};

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

  void _toggleOption(int index) {
    if (_answered) return;
    setState(() {
      if (_selections.containsKey(index)) {
        _selections.remove(index);
      } else {
        _selections[index] = 5.0; // default intensity
      }
    });
  }

  void _updateIntensity(int index, double value) {
    if (_answered) return;
    setState(() {
      _selections[index] = value;
    });
  }

  void _submitAnswer() {
    if (_selections.isEmpty || _answered) return;
    setState(() => _answered = true);

    // Check if user rejected the verification type
    // (last option selected with intensity >= 7)
    final currentQ = _currentQuestion;
    final rejectIndex = currentQ.options.length - 1;
    final isTotalReject = currentQ.id.startsWith('verify') &&
        _selections.containsKey(rejectIndex) &&
        _selections[rejectIndex]! >= 7.0;

    if (isTotalReject) {
      Future.delayed(const Duration(milliseconds: 400), () => _showRetestDialog());
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      // Build weighted selections: [(optionIndex, intensity)]
      final weightedSelections = _selections.entries
          .map((e) => MapEntry(e.key, e.value.round()))
          .toList();

      widget.engine.submitAnswer(weightedSelections);

      if (!widget.engine.hasMoreQuestions ||
          widget.engine.state.phase == AssessmentPhase.result) {
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
        _selections.clear();
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
      _selections.clear();
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

                      // Options — checkbox + intensity slider
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _currentQuestion.options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (ctx, i) {
                            final opt = _currentQuestion.options[i];
                            final isSelected = _selections.containsKey(i);
                            final intensity = _selections[i] ?? 5.0;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.cta.withValues(alpha: 0.06)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.cta.withValues(alpha: 0.4)
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Checkbox row ──
                                    InkWell(
                                      onTap: _answered ? null : () => _toggleOption(i),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(6),
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
                                                      size: 16, color: Colors.white)
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
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
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // ── Intensity slider (only when selected) ──
                                    if (isSelected) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text('強度',
                                            style: GoogleFonts.notoSansTc(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor: AppColors.cta,
                                                inactiveTrackColor: AppColors.border,
                                                thumbColor: AppColors.cta,
                                                overlayColor: AppColors.cta.withValues(alpha: 0.12),
                                                trackHeight: 4,
                                                thumbShape: const RoundSliderThumbShape(
                                                  enabledThumbRadius: 8,
                                                ),
                                                valueIndicatorColor: AppColors.cta,
                                                valueIndicatorTextStyle: GoogleFonts.notoSansTc(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              child: Slider(
                                                value: intensity,
                                                min: 1,
                                                max: 10,
                                                divisions: 9,
                                                label: intensity.round().toString(),
                                                onChanged: _answered
                                                    ? null
                                                    : (v) => _updateIntensity(i, v),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 28,
                                            child: Text(
                                              intensity.round().toString(),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.notoSansTc(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.cta,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
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
                      onPressed: _answered || _selections.isEmpty
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
                      child: Text(_selections.isNotEmpty
                          ? '確認答案（${_selections.length}項）'
                          : '揀選項以繼續'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '揀幾多個都得 · 滑條表示你有幾同意（1–10）',
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

  void _showRetestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔄', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('我哋會根據你既答案\\n重新調整問題，再試多次？',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifTc(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.6),
            ),
            const SizedBox(height: 8),
            Text('今次會更精準針對你既情況',
              style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.engine.reset();
                  setState(() {
                    _currentQuestion = widget.engine.getCurrentQuestion();
                    _answered = false;
                    _selections.clear();
                  });
                  _slideCtrl.reset();
                  _slideCtrl.forward();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  textStyle: GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('好，再試一次'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Build weighted selections from current state
                final weightedSelections = _selections.entries
                    .map((e) => MapEntry(e.key, e.value.round()))
                    .toList();
                widget.engine.submitAnswer(weightedSelections);
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
                } else {
                  setState(() {
                    _currentQuestion = widget.engine.getCurrentQuestion();
                    _answered = false;
                    _selections.clear();
                  });
                  _slideCtrl.reset();
                  _slideCtrl.forward();
                }
              },
              child: const Text('繼續用現有結果', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
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
