// ═══════════════════════════════════════════════════════════════════════
// BigFiveScorer — 大五人格計分引擎
// Each dimension: 2 questions, each 1–5 → avg → normalize to 0–100
// ═══════════════════════════════════════════════════════════════════════

import 'big_five_model.dart';

class BigFiveScorer {
  /// Calculate Big Five scores from { question_id: selected_score } map
  /// Answers map keys: O1, O2, C1, C2, E1, E2, A1, A2, N1, N2
  static BigFiveResult calculate(Map<String, int> answers) {
    double dimensionScore(String prefix) {
      final q1 = answers['${prefix}1'] ?? 3;
      final q2 = answers['${prefix}2'] ?? 3;
      // Convert 1–5 average → 0–100
      return ((q1 + q2) / 2 - 1) / 4 * 100;
    }

    return BigFiveResult(
      openness: dimensionScore('O'),
      conscientiousness: dimensionScore('C'),
      extraversion: dimensionScore('E'),
      agreeableness: dimensionScore('A'),
      neuroticism: dimensionScore('N'),
    );
  }

  /// Format a score to 0 decimal places with % sign
  static String formatScore(double score) => '${score.round()}%';

  /// Emoji for a dimension given its score
  static String dimensionEmoji(String dimension, double score) {
    switch (dimension) {
      case 'O':
        return '🌍';
      case 'C':
        return '🎯';
      case 'E':
        return '🗣️';
      case 'A':
        return '💛';
      case 'N':
        return '🌊';
      default:
        return '❓';
    }
  }

  /// Color indicator for score level
  static String scoreColor(double score) {
    if (score >= 75) return '🔴';
    if (score >= 50) return '🟠';
    if (score >= 25) return '🟡';
    return '🟢';
  }
}
