// ═══════════════════════════════════════════════════════════════════════
// ScoringEngine — v2 Confidence-Weighted Scoring System
// MBTI + 九型人格 Weighted Scoring with Verification Bonuses
// ═══════════════════════════════════════════════════════════════════════

import 'decision_state.dart';

class ScoringEngine {
  /// Phase 1 double-dip weight (less direct)
  static const double phase1Weight = 0.5;

  /// Phase 3 targeted weight
  static const double phase3Weight = 0.85;

  /// Verification confirmation boost
  static const double verificationBoost = 1.15;

  /// Calculate final MBTI result
  MBTIResult calculateMBTI(DecisionState state) {
    final dimResults = state.computeDimensionResults();

    // Build full type string
    final type = '${dimResults['EI']}${dimResults['SN']}${dimResults['TF']}${dimResults['JP']}';

    // Dimension scores
    final dimScores = Map<String, double>.from(state.mbtiScores);

    // Apply verification boost if confirmed
    if (state.mbtiVerification?.outcome == VerificationOutcome.confirmed) {
      for (final key in dimScores.keys.toList()) {
        dimScores[key] = dimScores[key]! * verificationBoost;
      }
    }

    // Calculate overall confidence
    final confidence = calculateOverallConfidence(state);

    return MBTIResult(
      type: type,
      confidence: confidence,
      dimensionScores: dimScores,
      dimensionConfidences: Map.from(state.dimensionConfidence),
      verification: state.mbtiVerification,
    );
  }

  /// Calculate overall MBTI confidence (average of 4 dimensions)
  double calculateOverallConfidence(DecisionState state) {
    double total = 0;
    for (final entry in state.dimensionConfidence.entries) {
      total += entry.value;
    }
    final base = total / 4;

    // Verification bonus
    if (state.mbtiVerification?.outcome == VerificationOutcome.confirmed) {
      return (base * verificationBoost).clamp(0.0, 1.0);
    }

    return base.clamp(0.0, 1.0);
  }

  /// Calculate final Enneagram result
  EnneaResult calculateEnneagram(DecisionState state) {
    final Map<int, double> finalScores = {};

    for (int type = 1; type <= 9; type++) {
      double score = 0;

      for (final answer in state.answerRecords) {
        final enneaKey = 'enneagram_$type';
        final answerScore = answer.scores[enneaKey] ?? 0;
        if (answerScore == 0) continue;

        // Weight by phase
        final weight = (answer.phase == DecisionPhase.enneaDeep ||
                answer.phase == DecisionPhase.enneaWingHealth ||
                answer.phase == DecisionPhase.enneaCenter)
            ? phase3Weight
            : phase1Weight;

        score += answerScore * weight;
      }

      // Verification bonus
      if (state.enneaVerification?.outcome == VerificationOutcome.confirmed &&
          state.enneaVerification?.typeCode == type.toString()) {
        score *= verificationBoost;
      }

      finalScores[type] = score;
    }

    // Determine primary type
    final sorted = finalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final primaryType = sorted.isNotEmpty ? sorted.first.key : 5;
    final typeConfidence = _calculateEnneaConfidence(finalScores, primaryType);

    // Determine wing
    final int? wing = _determineWing(primaryType, finalScores);

    // Health level
    final healthLevel = _determineHealthLevel(state.healthScore);

    return EnneaResult(
      primaryType: primaryType,
      wing: wing,
      display: '$primaryType${wing != null ? 'w$wing' : ''}',
      confidence: typeConfidence,
      typeScores: finalScores,
      healthLevel: healthLevel,
      healthScore: state.healthScore,
      verification: state.enneaVerification,
    );
  }

  /// Calculate confidence for a specific enneagram type
  double _calculateEnneaConfidence(Map<int, double> scores, int primaryType) {
    final primary = scores[primaryType] ?? 0;
    final second = scores.entries
        .where((e) => e.key != primaryType)
        .map((e) => e.value)
        .fold(0.0, (a, b) => a > b ? a : b);

    final total = primary + second;
    if (total == 0) return 0.0;

    final raw = ((primary - second) / total).clamp(0.0, 1.0);
    return raw;
  }

  /// Determine wing type based on scores
  int? _determineWing(int primaryType, Map<int, double> scores) {
    // Each enneagram type has two possible wings
    final wingOptions = _wingTypes(primaryType);

    if (wingOptions.length < 2) return null;

    final wing1Score = scores[wingOptions[0]] ?? 0;
    final wing2Score = scores[wingOptions[1]] ?? 0;

    // Threshold: wing must have at least 40% of primary score
    final primaryScore = scores[primaryType] ?? 0;
    if (primaryScore == 0) return null;

    if (wing1Score > wing2Score && wing1Score / primaryScore > 0.3) {
      return wingOptions[0];
    } else if (wing2Score / primaryScore > 0.3) {
      return wingOptions[1];
    }

    // Default wing based on enneagram tradition
    return _defaultWing(primaryType);
  }

  /// Get possible wings for a type
  List<int> _wingTypes(int type) {
    switch (type) {
      case 1:
        return [9, 2];
      case 2:
        return [1, 3];
      case 3:
        return [2, 4];
      case 4:
        return [3, 5];
      case 5:
        return [4, 6];
      case 6:
        return [5, 7];
      case 7:
        return [6, 8];
      case 8:
        return [7, 9];
      case 9:
        return [8, 1];
      default:
        return [];
    }
  }

  /// Default wing based on common enneagram pairings
  int? _defaultWing(int type) {
    switch (type) {
      case 1:
        return 9;
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 5;
      case 5:
        return 4;
      case 6:
        return 5;
      case 7:
        return 6;
      case 8:
        return 7;
      case 9:
        return 1;
      default:
        return null;
    }
  }

  /// Determine health level label
  String _determineHealthLevel(double healthScore) {
    if (healthScore >= 0.7) return 'healthy';
    if (healthScore >= 0.4) return 'average';
    return 'unhealthy';
  }

  /// Calculate per-dimension confidence display
  static double dimensionConfidence(double a, double b) {
    final diff = (a - b).abs();
    final total = a.abs() + b.abs();
    if (total < 0.001) return 0.0;
    return (diff / total).clamp(0.0, 1.0);
  }

  /// Detect cognitive biases from answer records
  static List<String> detectCognitiveBiases(List<AnswerRecord> answers) {
    final biases = <String>[];
    double internalAttr = 0, catastrophizing = 0;
    double emotionalSuppress = 0, perfectionism = 0;
    double overthinking = 0, peoplePleasing = 0;

    for (final a in answers) {
      internalAttr += a.scores['bias_internal_attribution'] ?? 0;
      catastrophizing += a.scores['bias_catastrophizing'] ?? 0;
      emotionalSuppress += a.scores['bias_emotional_suppress'] ?? 0;
      perfectionism += a.scores['enneagram_1'] ?? 0; // proxy
      overthinking += a.scores['enneagram_5'] ?? 0; // proxy
      peoplePleasing += a.scores['enneagram_2'] ?? 0; // proxy
    }

    if (internalAttr > 1.5) biases.add('內歸因偏誤');
    if (catastrophizing > 1.5) biases.add('災難化思考');
    if (emotionalSuppress > 1.5) biases.add('情感壓抑');
    if (perfectionism > 3.0) biases.add('完美主義傾向');
    if (overthinking > 3.0) biases.add('過度分析傾向');
    if (peoplePleasing > 3.0 && emotionalSuppress > 1.0) {
      biases.add('討好傾向');
    }

    return biases;
  }
}
