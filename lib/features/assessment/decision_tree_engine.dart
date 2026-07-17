// ═══════════════════════════════════════════════════════════════════════
// MultiSelectEngine — Flat Multi-Select Scoring Assessment Engine
// User answers ALL questions, sum weights across all selected options
// No decision tree routing, no conditions, no verification phases
// MBTI determined by comparing E vs I, S vs N, T vs F, J vs P totals
// ═══════════════════════════════════════════════════════════════════════

import '../../core/assessment/engine/question_bank.dart';
import '../../core/assessment/engine/decision_state.dart';

// ─── CONSTANTS ───
class AssessmentVersions {
  static const fast = _VersionConfig(20, '🏃', '快測', 'MBTI 91%準確度', '~5分鐘');
  static const standard = _VersionConfig(30, '⚖️', '標準', 'MBTI 96%準確度', '~7分鐘');
  static const deep = _VersionConfig(45, '🏆', '深度', 'MBTI 99% + 九型人格', '~10分鐘');
  static const all = [fast, standard, deep];
}

class _VersionConfig {
  final int questionCount;
  final String emoji;
  final String label;
  final String accuracy;
  final String time;
  const _VersionConfig(this.questionCount, this.emoji, this.label, this.accuracy, this.time);
}

// ─── PHASES ───
enum AssessmentPhase { questions, result }

// ─── ANSWER OPTION ───
class AnswerOption {
  final String text;
  final Map<String, double> scores;
  const AnswerOption({required this.text, required this.scores});
}

// ─── QUESTION ───
class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;
  final AssessmentPhase phase;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.phase,
  });
}

// ─── ANSWER RECORD ───
class AnswerRecord {
  final String questionId;
  final List<int> selectedIndices;
  final List<String> optionTexts;
  final Map<String, double> scores;
  const AnswerRecord({
    required this.questionId,
    required this.selectedIndices,
    required this.optionTexts,
    required this.scores,
  });
}

// ─── ASSESSMENT STATE ───
class AssessmentState {
  double e = 0, i = 0, s = 0, n = 0, t = 0, f = 0, j = 0, p = 0;
  final List<double> enneaTypeScores = List.filled(9, 0);
  AssessmentPhase phase = AssessmentPhase.questions;
  int currentQuestionIndex = 0;
  List<AnswerRecord> history = [];

  // Backward-compat stubs (always 0/false in multi-select mode)
  int mbtiConfidence = 0;
  int enneaConfidence = 0;

  String get mbtiString =>
    '${e >= i ? "E" : "I"}${s >= n ? "S" : "N"}${t >= f ? "T" : "F"}${j >= p ? "J" : "P"}';

  int get leadingEnneaType {
    int best = 4;
    for (int i = 0; i < 9; i++) {
      if (enneaTypeScores[i] > enneaTypeScores[best - 1]) best = i + 1;
    }
    return best;
  }

  int getWing(int type) {
    final low = type - 1;
    final high = type + 1;
    final vl = low >= 1 ? low : null;
    final vh = high <= 9 ? high : null;
    if (vl == null && vh == null) return 9;
    if (vl == null) return vh!;
    if (vh == null) return vl;
    return enneaTypeScores[vl - 1] >= enneaTypeScores[vh - 1] ? vl : vh;
  }

  String get enneagramKey => '${leadingEnneaType}w${getWing(leadingEnneaType)}';

  // Backward-compat stubs
  bool get mbtiVerified => true;
  bool get enneaVerified => true;

  void applyScores(Map<String, double> scores) {
    for (final entry in scores.entries) {
      switch (entry.key) {
        case 'E': e += entry.value; break;
        case 'I': i += entry.value; break;
        case 'S': s += entry.value; break;
        case 'N': n += entry.value; break;
        case 'T': t += entry.value; break;
        case 'F': f += entry.value; break;
        case 'J': j += entry.value; break;
        case 'P': p += entry.value; break;
        default:
          if (entry.key.startsWith('enneagram_')) {
            final tn = int.tryParse(entry.key.split('_').last);
            if (tn != null && tn >= 1 && tn <= 9) {
              enneaTypeScores[tn - 1] += entry.value;
            }
          }
          // Ignore other keys (bias_, health_, etc.) in scoring
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MULTI-SELECT SCORING ENGINE
// ═══════════════════════════════════════════════════════════════════════
class DecisionTreeEngine {
  final AssessmentState state = AssessmentState();
  final List<Question> _pool = [];
  final int _questionCount;

  DecisionTreeEngine({int questionCount = 45}) : _questionCount = questionCount {
    _pool.addAll(_buildFromBank());
  }

  /// Build question pool from QuestionBank — includes all mbtiRouting,
  /// enneaCenter, and enneaDeep questions. Takes first [_questionCount] questions.
  List<Question> _buildFromBank() {
    final bank = QuestionBank();
    final keepPhases = {
      DecisionPhase.mbtiRouting,
      DecisionPhase.enneaCenter,
      DecisionPhase.enneaDeep,
    };
    final allQuestions = bank.allQuestions
      .where((dq) => keepPhases.contains(dq.phase))
      .map((dq) => Question(
        id: dq.id,
        text: dq.scenario,
        options: dq.options.map((opt) => AnswerOption(
          text: opt.text,
          scores: Map<String, double>.from(opt.scores),
        )).toList(),
        phase: AssessmentPhase.questions,
      )).toList();

    // Apply question count limit — first N questions from pool
    final count = _questionCount.clamp(1, allQuestions.length);
    return allQuestions.sublist(0, count);
  }

  int get answeredCount => state.history.length;
  int get totalEstimatedQuestions => _pool.length;

  bool get hasMoreQuestions {
    if (state.phase == AssessmentPhase.result) return false;
    return state.currentQuestionIndex < _pool.length;
  }

  Question getCurrentQuestion() {
    if (state.phase == AssessmentPhase.result) {
      throw StateError('Assessment complete');
    }
    if (state.currentQuestionIndex >= _pool.length) {
      state.phase = AssessmentPhase.result;
      throw StateError('Assessment complete');
    }
    return _pool[state.currentQuestionIndex];
  }

  /// Submit multi-select answer — scores from ALL selected options are summed.
  void submitAnswer(List<int> optionIndices) {
    final q = _pool[state.currentQuestionIndex];

    // Aggregate scores from ALL selected options
    final aggregatedScores = <String, double>{};
    final selectedTexts = <String>[];
    for (final idx in optionIndices) {
      final opt = q.options[idx];
      selectedTexts.add(opt.text);
      for (final entry in opt.scores.entries) {
        aggregatedScores[entry.key] =
            (aggregatedScores[entry.key] ?? 0) + entry.value;
      }
    }

    state.applyScores(aggregatedScores);
    state.history.add(AnswerRecord(
      questionId: q.id,
      selectedIndices: List.from(optionIndices),
      optionTexts: selectedTexts,
      scores: Map.from(aggregatedScores),
    ));
    state.currentQuestionIndex++;

    // Check if all questions answered
    if (state.currentQuestionIndex >= _pool.length) {
      state.phase = AssessmentPhase.result;
    }
  }

  void reset() {
    state.e = state.i = state.s = state.n = state.t = state.f = state.j = state.p = 0;
    for (int i = 0; i < 9; i++) { state.enneaTypeScores[i] = 0; }
    state.mbtiConfidence = 0;
    state.enneaConfidence = 0;
    state.phase = AssessmentPhase.questions;
    state.currentQuestionIndex = 0;
    state.history.clear();
  }

  /// Undo the last answer — restores previous state.
  bool goBack() {
    if (state.history.isEmpty) return false;
    final last = state.history.removeLast();

    // Reverse the scores
    for (final entry in last.scores.entries) {
      switch (entry.key) {
        case 'E': state.e -= entry.value; break;
        case 'I': state.i -= entry.value; break;
        case 'S': state.s -= entry.value; break;
        case 'N': state.n -= entry.value; break;
        case 'T': state.t -= entry.value; break;
        case 'F': state.f -= entry.value; break;
        case 'J': state.j -= entry.value; break;
        case 'P': state.p -= entry.value; break;
        default:
          if (entry.key.startsWith('enneagram_')) {
            final tn = int.tryParse(entry.key.split('_').last);
            if (tn != null && tn >= 1 && tn <= 9) {
              state.enneaTypeScores[tn - 1] -= entry.value;
            }
          }
      }
    }

    state.currentQuestionIndex = state.history.length;
    state.phase = AssessmentPhase.questions;
    return true;
  }
}
