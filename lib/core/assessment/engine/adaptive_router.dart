// ═══════════════════════════════════════════════════════════════════════
// AdaptiveRouter — v2 Decision Tree State Machine Router
// Dynamic next-question selection based on uncertainty + phase
// ═══════════════════════════════════════════════════════════════════════

import 'decision_state.dart';
import 'question_bank.dart';
import 'personality_verifier.dart';

/// Core decision tree router — determines next question based on live state
class DecisionTreeRouter {
  final QuestionBank _bank;
  final PersonalityVerifier _verifier;

  DecisionTreeRouter({
    QuestionBank? bank,
    PersonalityVerifier? verifier,
  })  : _bank = bank ?? QuestionBank(),
        _verifier = verifier ?? PersonalityVerifier();

  /// ─── MAIN ENTRY POINT ───
  /// Returns the next question based on current state
  DecisionQuestion nextQuestion(DecisionState state) {
    switch (state.phase) {
      case DecisionPhase.mbtiRouting:
        return _routeMBTI(state);
      case DecisionPhase.mbtiVerification:
        return _routeMbtiVerification(state);
      case DecisionPhase.mbtiFineTuning:
        return _routeMbtiFineTuning(state);
      case DecisionPhase.mbtiReRouting:
        return _routeMbtiReRouting(state);
      case DecisionPhase.enneaCenter:
        return _routeEnneaCenter(state);
      case DecisionPhase.enneaDeep:
        return _routeEnneaDeep(state);
      case DecisionPhase.enneaWingHealth:
        return _routeEnneaWingHealth(state);
      case DecisionPhase.enneaVerification:
        return _routeEnneaVerification(state);
      case DecisionPhase.enneaAdjustment:
        return _routeEnneaAdjustment(state);
      case DecisionPhase.complete:
        // Shouldn't be called when complete; return last question
        return _bank.getLastQuestion();
    }
  }

  /// ─── PHASE 1: MBTI ROUTING ───
  DecisionQuestion _routeMBTI(DecisionState state) {
    final answered = state.answeredCount;

    // Q1: Always E/I screening (first question)
    if (answered == 0) {
      state.estimatedTotal = 14;
      final q1 = _bank.getQuestion('DQ_EI_01');
      state.decisionPath = 'Q1';
      return q1;
    }

    // After Q1: route based on E/I choice
    if (answered == 1) {
      // Determine which path user took
      final eScore = state.mbtiScores['E'] ?? 0;
      final iScore = state.mbtiScores['I'] ?? 0;
      final isE = eScore >= iScore;

      state.decisionPath += isE ? '→E' : '→I';
      return isE ? _bank.getQuestion('DQ_TFJP_E') : _bank.getQuestion('DQ_TFJP_I');
    }

    // After Q2: S/N confirmation
    if (answered == 2) {
      state.decisionPath += '→Q3';
      return _bank.getQuestion('DQ_SN_03');
    }

    // Q4-Q6: Dynamic based on uncertainty
    final uncertain = state.getTopUncertainDimensions(2);
    final mostUncertain = state.getMostUncertainDimension();

    // If all dimensions confident enough and at least 4 questions answered → verification
    if (uncertain.isEmpty && answered >= 4) {
      return _transitionToMbtiVerification(state);
    }

    // Need at least 4 questions before verification
    if (answered >= 6) {
      // Force transition after 6 questions regardless
      return _transitionToMbtiVerification(state);
    }

    // Q4: Dynamic question for most uncertain dimension
    if (answered == 3) {
      state.decisionPath += '→Q4_$mostUncertain';
      return _getUncertaintyQuestion(mostUncertain);
    }

    // Q5: Compound question (万能key)
    if (answered == 4) {
      state.decisionPath += '→Q5';
      return _bank.getQuestion('DQ_MULTI_05');
    }

    // Q6 (if needed): Final clarification
    state.decisionPath += '→Q6';
    return _bank.getQuestion('DQ_FINAL_06');
  }

  /// ─── TRANSITION: Phase 1 → Phase 2 ───
  DecisionQuestion _transitionToMbtiVerification(DecisionState state) {
    state.tentativeMBTI = state.computeTentativeMBTI();
    state.phase = DecisionPhase.mbtiVerification;
    state.isMbtiVerificationActive = true;
    state.decisionPath += '→V';
    return _verifier.getMbtiVerificationQuestion(state.tentativeMBTI!);
  }

  /// ─── PHASE 2: MBTI VERIFICATION ───
  DecisionQuestion _routeMbtiVerification(DecisionState state) {
    // Verification question was already shown; this gets called after user answers
    // The verifier handles the response and transitions
    // This is a safety fallback
    if (state.mbtiVerification == null) {
      // Still waiting for verification answer — should not reach here
      return _verifier.getMbtiVerificationQuestion(
        state.tentativeMBTI ?? 'ENFJ',
      );
    }

    // Route based on verification outcome
    switch (state.mbtiVerification!.outcome) {
      case VerificationOutcome.confirmed:
        state.decisionPath += '_OK';
        return _transitionToEnneaCenter(state);
      case VerificationOutcome.adjusted:
        state.decisionPath += '_ADJ';
        state.phase = DecisionPhase.mbtiFineTuning;
        return _routeMbtiFineTuning(state);
      case VerificationOutcome.rerouted:
        state.decisionPath += '_RR';
        state.phase = DecisionPhase.mbtiReRouting;
        state.rerouteDepth++;
        return _routeMbtiReRouting(state);
    }
  }

  /// ─── PHASE 2b: MBTI FINE-TUNING ───
  DecisionQuestion _routeMbtiFineTuning(DecisionState state) {
    // Show dimension fine-tuning question
    final q = _bank.getQuestion('DQ_FT_JP'); // J/P fine-tune
    state.decisionPath += '→FT';
    return q;
  }

  /// ─── PHASE 2c: MBTI RE-ROUTING ───
  DecisionQuestion _routeMbtiReRouting(DecisionState state) {
    if (state.rerouteDepth > 2) {
      // Too many re-routes, force through
      state.phase = DecisionPhase.enneaCenter;
      return _routeEnneaCenter(state);
    }

    // Re-routing questions (E/I re-check)
    if (state.answeredCount < 10 &&
        state.answerRecords.where((r) => r.questionId == 'DQ_RR_EI').isEmpty) {
      return _bank.getQuestion('DQ_RR_EI');
    }

    state.decisionPath += '→RR_DONE';
    // Re-compute MBTI
    state.tentativeMBTI = state.computeTentativeMBTI();
    // Re-challenge with verification
    state.phase = DecisionPhase.mbtiVerification;
    state.isMbtiVerificationActive = true;
    return _verifier.getMbtiVerificationQuestion(state.tentativeMBTI!);
  }

  /// ─── TRANSITION: Phase 2 → Phase 3a ───
  DecisionQuestion _transitionToEnneaCenter(DecisionState state) {
    state.phase = DecisionPhase.enneaCenter;
    state.decisionPath += '→Q7';
    return _bank.getQuestion('DQ_ENNEA_3CENTER');
  }

  /// ─── PHASE 3a: ENNEAGRAM CENTER SCREENING ───
  DecisionQuestion _routeEnneaCenter(DecisionState state) {
    // Determine center from phase 1 data if possible; otherwise use Q7
    final topTypes = state.getTopEnneaTypes(3);
    final scores = state.enneagramScores;

    // Check if there's a clear center from accumulated data
    final heartScore = (scores[2] ?? 0) + (scores[3] ?? 0) + (scores[4] ?? 0);
    final headScore = (scores[5] ?? 0) + (scores[6] ?? 0) + (scores[7] ?? 0);
    final gutScore = (scores[8] ?? 0) + (scores[9] ?? 0) + (scores[1] ?? 0);

    // Find max center
    String detectedCenter;
    if (heartScore >= headScore && heartScore >= gutScore) {
      detectedCenter = 'heart';
    } else if (headScore >= heartScore && headScore >= gutScore) {
      detectedCenter = 'head';
    } else {
      detectedCenter = 'gut';
    }

    state.enneaCenter = detectedCenter;
    state.decisionPath += '→${_centerLabel(detectedCenter)}';
    state.phase = DecisionPhase.enneaDeep;
    return _routeEnneaDeep(state);
  }

  /// ─── PHASE 3b: ENNEAGRAM DEEP TYPE ───
  DecisionQuestion _routeEnneaDeep(DecisionState state) {
    final center = state.enneaCenter ?? 'head';
    final topInCenter = state.getTopEnneaInCenter(center);
    state.topEnneagramTypes = {};
    for (final t in topInCenter) {
      state.topEnneagramTypes[t] = state.enneagramScores[t] ?? 0;
    }

    switch (center) {
      case 'heart':
        state.decisionPath += '→Q8a';
        return _bank.getQuestion('DQ_ENNEA_HEART');
      case 'head':
        state.decisionPath += '→Q8b';
        return _bank.getQuestion('DQ_ENNEA_HEAD');
      case 'gut':
        state.decisionPath += '→Q8c';
        return _bank.getQuestion('DQ_ENNEA_GUT');
      default:
        state.decisionPath += '→Q8b';
        return _bank.getQuestion('DQ_ENNEA_HEAD');
    }
  }

  /// ─── TRANSITION: Phase 3b → Phase 3c ───
  void _transitionToEnneaWing(DecisionState state) {
    // Determine primary type from accumulated scores
    final sorted = state.enneagramScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isNotEmpty) {
      state.primaryEnneaType = sorted.first.key;
    }

    state.decisionPath += '→Q10';
    state.phase = DecisionPhase.enneaWingHealth;
  }

  /// ─── PHASE 3c: WING + HEALTH ───
  DecisionQuestion _routeEnneaWingHealth(DecisionState state) {
    final primaryType = state.primaryEnneaType ?? 5;
    state.decisionPath += '($primaryType)';

    // Wing + health question depends on primary type
    switch (primaryType) {
      case 2:
        return _bank.getQuestion('DQ_WING_2w1_2w3');
      case 3:
        return _bank.getQuestion('DQ_WING_3w2_3w4');
      case 4:
        return _bank.getQuestion('DQ_WING_4w3_4w5');
      case 5:
        return _bank.getQuestion('DQ_WING_5w4_5w6');
      case 6:
        return _bank.getQuestion('DQ_WING_6w5_6w7');
      case 7:
        return _bank.getQuestion('DQ_WING_7w6_7w8');
      case 8:
        return _bank.getQuestion('DQ_WING_8w7_8w9');
      case 9:
        return _bank.getQuestion('DQ_WING_9w8_9w1');
      case 1:
        return _bank.getQuestion('DQ_WING_1w9_1w2');
      default:
        return _bank.getQuestion('DQ_WING_5w4_5w6');
    }
  }

  /// ─── TRANSITION: Phase 3c → Phase 4 ───
  void _transitionToEnneaVerification(DecisionState state) {
    state.phase = DecisionPhase.enneaVerification;
    state.isEnneaVerificationActive = true;
    state.decisionPath += '→V_ENNEA';
  }

  /// ─── PHASE 4: ENNEAGRAM VERIFICATION ───
  DecisionQuestion _routeEnneaVerification(DecisionState state) {
    final primaryType = state.primaryEnneaType ?? 5;
    return _verifier.getEnneaVerificationQuestion(primaryType);
  }

  /// ─── PHASE 4b: ENNEAGRAM ADJUSTMENT ───
  DecisionQuestion _routeEnneaAdjustment(DecisionState state) {
    if (state.enneaVerification?.outcome == VerificationOutcome.rerouted) {
      // Try alternative type in same center
      final center = state.enneaCenter ?? 'head';
      final alternatives = DecisionState.centerTypes(center)
          .where((t) => t != state.primaryEnneaType)
          .toList();

      if (alternatives.isNotEmpty) {
        state.primaryEnneaType = alternatives.first;
        state.decisionPath += '→SWITCH_${alternatives.first}';
        // Re-verify with new type
        state.phase = DecisionPhase.enneaVerification;
        state.isEnneaVerificationActive = true;
        return _verifier.getEnneaVerificationQuestion(alternatives.first);
      }
    }

    // Final fallback: accept current result
    state.phase = DecisionPhase.complete;
    return _bank.getLastQuestion();
  }

  /// Handle verification answer from MBTI verification phase
  void handleMbtiVerificationAnswer(DecisionState state, String type, String answerCode) {
    state.isMbtiVerificationActive = false;

    switch (answerCode) {
      case 'A':
        state.mbtiVerification = VerificationResult(
          typeCode: type,
          outcome: VerificationOutcome.confirmed,
          confidence: 0.9,
        );
        state.phase = DecisionPhase.enneaCenter;
        break;
      case 'B':
        state.mbtiVerification = VerificationResult(
          typeCode: type,
          outcome: VerificationOutcome.adjusted,
          confidence: 0.6,
        );
        state.phase = DecisionPhase.mbtiFineTuning;
        break;
      case 'C':
        state.mbtiVerification = VerificationResult(
          typeCode: type,
          outcome: VerificationOutcome.rerouted,
          confidence: 0.3,
        );
        state.phase = DecisionPhase.mbtiReRouting;
        state.rerouteDepth++;
        break;
    }
  }

  /// Handle enneagram verification answer
  void handleEnneaVerificationAnswer(
    DecisionState state,
    int type,
    String answerCode, {
    int? selectedWing,
  }) {
    state.isEnneaVerificationActive = false;

    switch (answerCode) {
      case 'A':
        state.enneaVerification = VerificationResult(
          typeCode: type.toString(),
          outcome: VerificationOutcome.confirmed,
          confidence: 0.9,
        );
        if (selectedWing != null) state.enneaWing = selectedWing;
        state.phase = DecisionPhase.complete;
        break;
      case 'B':
        state.enneaVerification = VerificationResult(
          typeCode: type.toString(),
          outcome: VerificationOutcome.adjusted,
          confidence: 0.6,
        );
        if (selectedWing != null) state.enneaWing = selectedWing;
        state.phase = DecisionPhase.enneaAdjustment;
        break;
      case 'C':
        state.enneaVerification = VerificationResult(
          typeCode: type.toString(),
          outcome: VerificationOutcome.rerouted,
          confidence: 0.3,
        );
        state.phase = DecisionPhase.enneaAdjustment;
        break;
    }
  }

  /// ─── HELPERS ───

  /// Get dynamic uncertainty question based on most uncertain dimension
  DecisionQuestion _getUncertaintyQuestion(String? dimension) {
    switch (dimension) {
      case 'EI':
        return _bank.getQuestion('DQ_EI_UNCERTAIN');
      case 'SN':
        return _bank.getQuestion('DQ_SN_UNCERTAIN');
      case 'TF':
        return _bank.getQuestion('DQ_TF_UNCERTAIN');
      case 'JP':
        return _bank.getQuestion('DQ_JP_UNCERTAIN');
      default:
        return _bank.getQuestion('DQ_MULTI_05');
    }
  }

  /// Map center to Chinese label
  String _centerLabel(String center) {
    switch (center) {
      case 'heart':
        return '心區';
      case 'head':
        return '腦區';
      case 'gut':
        return '腹區';
      default:
        return center;
    }
  }
}
