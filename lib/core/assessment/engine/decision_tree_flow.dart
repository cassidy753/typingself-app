// ═══════════════════════════════════════════════════════════════════════
// DecisionTreeFlow — v2 Decision Tree UI Flow
// Replaces FirstTestFlow's 12 simple questions with adaptive engine
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'decision_state.dart';
import 'adaptive_router.dart';
import 'scoring_engine.dart';
import 'personality_verifier.dart';

/// Adaptive decision tree flow — replaces the static FirstTestFlow.
/// Uses DecisionTreeRouter for dynamic question routing,
/// ScoringEngine for final calculation, and PersonalityVerifier for
/// MBTI + Enneagram mindset verification.
class DecisionTreeFlow extends StatefulWidget {
  final void Function(String mbti, String ennea) onDone;

  const DecisionTreeFlow({super.key, required this.onDone});

  @override
  State<DecisionTreeFlow> createState() => _DecisionTreeFlowState();
}

class _DecisionTreeFlowState extends State<DecisionTreeFlow>
    with SingleTickerProviderStateMixin {
  final DecisionState _state = DecisionState();
  late final DecisionTreeRouter _router;
  final ScoringEngine _scorer = ScoringEngine();

  DecisionQuestion? _currentQuestion;
  int _questionNumber = 0;
  bool _transitioning = false;
  bool _isComplete = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    _router = DecisionTreeRouter();
    _currentQuestion = _router.nextQuestion(_state);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onAnswer(int optionIndex) {
    if (_transitioning || _isComplete) return;

    final question = _currentQuestion;
    if (question == null) return;

    final option = question.options[optionIndex];

    // Record answer in state
    _state.recordAnswer(question.id, option.scores, optionIndex);

    setState(() => _transitioning = true);
    _fadeCtrl.reverse().then((_) {
      // Handle verification answers
      if (question.id.startsWith('V_MBTI_')) {
        final answerCode = PersonalityVerifier.classifyVerificationAnswer(option.scores);
        _router.handleMbtiVerificationAnswer(
          _state,
          _state.tentativeMBTI ?? _state.computeTentativeMBTI(),
          answerCode,
        );
      } else if (question.id.startsWith('V_ENNEA_')) {
        final answerCode = PersonalityVerifier.classifyVerificationAnswer(option.scores);
        _router.handleEnneaVerificationAnswer(
          _state,
          _state.primaryEnneaType ?? 5,
          answerCode,
        );
      }

      // If at MBTI fine-tuning, apply the MBTI adjustment
      if (question.id == 'DQ_FT_JP') {
        _state.mbtiVerification = const VerificationResult(
          typeCode: 'adjusted',
          outcome: VerificationOutcome.confirmed,
          confidence: 0.7,
        );
        _state.phase = DecisionPhase.enneaCenter;
      }

      // If at ennea wing question, determine wing from answer
      if (question.id.startsWith('DQ_WING_')) {
        _state.enneaWing = _inferWingFromWingQuestion(question.id, optionIndex);
        // Transition to ennea verification
        _state.phase = DecisionPhase.enneaVerification;
        _state.isEnneaVerificationActive = true;
      }

      // If ennea adjustment results in switch, re-verify
      if (question.id == 'V_ENNEA_ADJUST') {
        _state.phase = DecisionPhase.complete;
      }

      // Check if re-routing is done → transition to ennea
      if (_state.phase == DecisionPhase.mbtiReRouting &&
          _state.answeredCount >= 10) {
        _state.phase = DecisionPhase.enneaCenter;
      }

      // Get next question
      _questionNumber++;
      _currentQuestion = _router.nextQuestion(_state);

      // Auto-transition: if ennea center already determined by data,
      // skip to deep automatically
      if (_state.phase == DecisionPhase.enneaDeep &&
          _currentQuestion?.phase == DecisionPhase.enneaCenter) {
        // Already transitioned by router
      }

      // Check if complete
      if (_state.phase == DecisionPhase.complete) {
        _isComplete = true;
        _finish();
        return;
      }

      setState(() => _transitioning = false);
      _fadeCtrl.forward();
    });
  }

  /// Infer wing type from wing question answer
  int? _inferWingFromWingQuestion(String questionId, int optionIndex) {
    // Wing questions have 2 options: option 0 = first wing, option 1 = second wing
    switch (questionId) {
      case 'DQ_WING_5w4_5w6':
        return optionIndex == 0 ? 4 : 6;
      case 'DQ_WING_2w1_2w3':
        return optionIndex == 0 ? 1 : 3;
      case 'DQ_WING_9w8_9w1':
        return optionIndex == 0 ? 8 : 1;
      case 'DQ_WING_3w2_3w4':
        return optionIndex == 0 ? 2 : 4;
      case 'DQ_WING_4w3_4w5':
        return optionIndex == 0 ? 3 : 5;
      case 'DQ_WING_6w5_6w7':
        return optionIndex == 0 ? 5 : 7;
      case 'DQ_WING_7w6_7w8':
        return optionIndex == 0 ? 6 : 8;
      case 'DQ_WING_8w7_8w9':
        return optionIndex == 0 ? 7 : 9;
      case 'DQ_WING_1w9_1w2':
        return optionIndex == 0 ? 9 : 2;
      default:
        return null;
    }
  }

  void _finish() {
    // Calculate final results
    final mbtiResult = _scorer.calculateMBTI(_state);
    final enneaResult = _scorer.calculateEnneagram(_state);

    // Save diagnostic record to state
    final diagnosticPath = '${_state.decisionPath}→DONE';

    // Persist via callback
    widget.onDone(mbtiResult.type, enneaResult.display);
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    if (q == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = (_state.answeredCount / _state.estimatedTotal).clamp(0.0, 1.0);
    // Show phase label in progress bar
    final phaseLabel = _state.getPhaseLabel();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Top bar: back + progress ──
              Row(
                children: [
                  GestureDetector(
                    onTap: _questionNumber > 0 && !_isComplete
                        ? null /* no back in decision tree */
                        : null,
                    child: const SizedBox(width: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phase label
                        Text(
                          phaseLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cta,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cta,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Question count
                        Text(
                          '第${_state.answeredCount + 1}題 / 約${_state.estimatedTotal}題',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Confidence indicators (for MBTI phase) ──
              if (_state.phase == DecisionPhase.mbtiRouting ||
                  _state.phase == DecisionPhase.mbtiVerification)
                _buildConfidenceIndicators(),

              const SizedBox(height: 16),

              // ── Question card (with fade transition) ──
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildQuestionCard(q),
                ),
              ),

              // ── Bottom indicator ──
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isComplete
                          ? null
                          : () {
                              // Skip to results (emergency exit)
                              setState(() => _isComplete = true);
                              _finish();
                            },
                      child: Text(
                        '快速完成 →',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      '${_state.answeredCount + 1}/${_state.estimatedTotal}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
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

  /// ─── CONFIDENCE INDICATORS ───
  Widget _buildConfidenceIndicators() {
    final dims = ['EI', 'SN', 'TF', 'JP'];
    final labels = {
      'EI': 'E/I',
      'SN': 'S/N',
      'TF': 'T/F',
      'JP': 'J/P',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: dims.map((dim) {
          final conf = _state.dimensionConfidence[dim] ?? 0;
          final barColor = conf > 0.6
              ? AppColors.sage
              : conf > 0.35
                  ? AppColors.mustard
                  : AppColors.cta.withValues(alpha: 0.6);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[dim]!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: conf.clamp(0.05, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(barColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(conf * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ─── QUESTION CARD ───
  Widget _buildQuestionCard(DecisionQuestion q) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Scenario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              q.scenario,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifTc(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Options
          ...List.generate(q.options.length, (i) {
            final opt = q.options[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _onAnswer(i),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: AppColors.border),
                    ),
                    textStyle: GoogleFonts.notoSansTc(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        // Option letter indicator
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.cta.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + i), // A, B, C, D
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cta,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt.text,
                            style: GoogleFonts.notoSansTc(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
