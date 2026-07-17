// ═══════════════════════════════════════════════════════════════════════
// DecisionTreeEngine v2 — Adaptive MBTI × Enneagram Assessment Engine
// Self-contained: no external engine dependencies
// Double-dip encoding · Dynamic branching · Cumulative confidence
// ═══════════════════════════════════════════════════════════════════════

// ─── PHASES ───
enum AssessmentPhase { intro, mbti, mbtiVerification, enneagram, enneagramVerification, result }

// ─── ANSWER OPTION ───
class AnswerOption {
  final String text;
  final Map<String, int> scores;
  final String? nextQuestionId;
  const AnswerOption({required this.text, required this.scores, this.nextQuestionId});
}

// ─── QUESTION ───
class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;
  final AssessmentPhase phase;
  final String? condition;
  final String? customPrompt;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.phase,
    this.condition,
    this.customPrompt,
  });
}

// ─── WEIGHTED SELECTION (multi-select with intensity) ───
class WeightedSelection {
  final int optionIndex;
  final int intensity; // 1–10
  const WeightedSelection({required this.optionIndex, required this.intensity});
}

// ─── ANSWER RECORD ───
class AnswerRecord {
  final String questionId;
  final List<WeightedSelection> selections;
  final String optionText; // joined with " | "
  final Map<String, int> scores; // weighted scores already aggregated
  const AnswerRecord({
    required this.questionId,
    required this.selections,
    required this.optionText,
    required this.scores,
  });
}

// ─── ASSESSMENT STATE ───
class AssessmentState {
  int e = 0, i = 0, s = 0, n = 0, t = 0, f = 0, j = 0, p = 0;
  int heart = 0, head = 0, gut = 0;
  final List<int> enneaTypeScores = List.filled(9, 0);
  int mbtiConfidence = 0;
  int enneaConfidence = 0;
  AssessmentPhase phase = AssessmentPhase.intro;
  int currentQuestionIndex = 0;
  List<AnswerRecord> history = [];
  String? predictedMbti;

  String get mbtiString =>
    '${e >= i ? "E" : "I"}${s >= n ? "S" : "N"}${t >= f ? "T" : "F"}${j >= p ? "J" : "P"}';

  String get leadingCenter {
    final m = [heart, head, gut];
    final i = m.indexOf(m.reduce((a, b) => a >= b ? a : b));
    return ['Heart', 'Head', 'Gut'][i];
  }

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

  bool get mbtiVerified => mbtiConfidence >= 1;
  bool get enneaVerified => enneaConfidence >= 1;

  void applyScores(Map<String, int> scores) {
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
        case 'Heart': heart += entry.value; break;
        case 'Head': head += entry.value; break;
        case 'Gut': gut += entry.value; break;
        case 'Verify': mbtiConfidence += entry.value; break;
        case 'EVerify': enneaConfidence += entry.value; break;
        default:
          final tn = int.tryParse(entry.key);
          if (tn != null && tn >= 1 && tn <= 9) enneaTypeScores[tn - 1] += entry.value;
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DECISION TREE ENGINE
// ═══════════════════════════════════════════════════════════════════════
class DecisionTreeEngine {
  final AssessmentState state = AssessmentState();
  final List<Question> _pool = [];

  DecisionTreeEngine() {
    _pool.addAll(_buildPool());
  }

  List<Question> _buildPool() => [
    // ═══ Phase 1: MBTI ═══
    const Question(id: 'mbti_01', text: '放假嗰日，你最想點過？', phase: AssessmentPhase.mbti, options: [
      AnswerOption(text: '約成班朋友出去癲', scores: {'E': 3, 'Heart': 2, 'F': 1}),
      AnswerOption(text: '自己去咖啡店 hea 一日', scores: {'I': 2, 'Head': 1, 'N': 1}),
      AnswerOption(text: '同幾個密友 chill 下', scores: {'E': 2, 'Heart': 2, 'F': 1}),
      AnswerOption(text: '喺屋企打機/煲劇', scores: {'I': 3, 'Gut': 2, 'S': 1}),
    ]),
    const Question(id: 'mbti_02_e', text: '你喺 group 入面通常做咩角色？', phase: AssessmentPhase.mbti, condition: 'E>I', options: [
      AnswerOption(text: '搞氣氛嗰個', scores: {'E': 2, 'Heart': 2, 'F': 2}),
      AnswerOption(text: '俾意見嗰個', scores: {'E': 1, 'Head': 2, 'T': 2}),
      AnswerOption(text: '跟大隊嗰個', scores: {'S': 2, 'Heart': 1, 'F': 1}),
      AnswerOption(text: '做決定嗰個', scores: {'E': 1, 'Gut': 2, 'T': 2}),
    ]),
    const Question(id: 'mbti_02_i', text: '你自己一個嘅時候最鍾意做咩？', phase: AssessmentPhase.mbti, condition: 'I>=E', options: [
      AnswerOption(text: '諗將來、plan 大計', scores: {'I': 2, 'N': 3, 'Head': 1}),
      AnswerOption(text: '做手作/整理房間', scores: {'I': 1, 'S': 2, 'Gut': 1}),
      AnswerOption(text: '睇書/上網吸收知識', scores: {'I': 2, 'N': 1, 'Head': 2}),
      AnswerOption(text: '發吓白日夢', scores: {'I': 2, 'N': 2, 'Heart': 1, '4': 1}),
    ]),
    const Question(id: 'mbti_03', text: '你平時較容易記得…', phase: AssessmentPhase.mbti, options: [
      AnswerOption(text: '具體發生過嘅細節', scores: {'S': 3, 'Gut': 1, '6': 1}),
      AnswerOption(text: '整體嘅感覺同印象', scores: {'N': 3, 'Heart': 2, '4': 1}),
      AnswerOption(text: '人講過嘅重點同邏輯', scores: {'N': 2, 'T': 2, 'Head': 2}),
      AnswerOption(text: '做過嘅事同程序', scores: {'S': 2, 'J': 2, '1': 1}),
    ]),
    const Question(id: 'mbti_04', text: '做一個重要決定之前，你最靠咩？', phase: AssessmentPhase.mbti, options: [
      AnswerOption(text: '分析晒所有 pros and cons', scores: {'T': 3, 'Head': 2, '5': 1}),
      AnswerOption(text: '跟住自己個心行', scores: {'F': 3, 'Heart': 3, '4': 1}),
      AnswerOption(text: '問信得過嘅人嘅意見', scores: {'F': 2, 'S': 1, 'Heart': 1, '6': 1}),
      AnswerOption(text: '邊個 option 最有效率', scores: {'T': 2, 'J': 2, 'Gut': 1, '3': 1}),
    ]),
    const Question(id: 'mbti_05', text: '去旅行你會點 plan？', phase: AssessmentPhase.mbti, options: [
      AnswerOption(text: 'Plan 到盡每個鐘都安排好', scores: {'J': 3, 'S': 2, '1': 2}),
      AnswerOption(text: '訂咗機票就算，去到再算', scores: {'P': 3, 'N': 2, 'Heart': 1, '7': 1}),
      AnswerOption(text: 'Plan 大方向，留啲彈性', scores: {'J': 1, 'N': 2, 'Head': 1}),
      AnswerOption(text: '跟朋友安排，我冇所謂', scores: {'P': 2, 'S': 1, 'F': 1, '9': 1}),
    ]),
    const Question(id: 'mbti_06', text: '朋友傷心嗰陣，你會…', phase: AssessmentPhase.mbti, options: [
      AnswerOption(text: '即刻安慰佢，問佢發生咩事', scores: {'F': 2, 'E': 1, 'Heart': 2, '2': 1}),
      AnswerOption(text: '靜靜陪喺身邊，唔出聲', scores: {'F': 2, 'I': 1, 'Heart': 1, '9': 1}),
      AnswerOption(text: '幫佢分析點樣解決問題', scores: {'T': 2, 'N': 1, 'Head': 2, '5': 1}),
      AnswerOption(text: '分享自己類似經歷', scores: {'E': 1, 'F': 1, 'Heart': 1, '2': 1}),
    ]),

    // ═══ Phase 2: MBTI Verification ═══
    const Question(id: 'verify_mbti', text: '作為一個 {MBTI}，你覺得以下邊句最似你？', phase: AssessmentPhase.mbtiVerification, customPrompt: '作為一個 {MBTI}，你覺得以下邊句最似你？', options: [
      AnswerOption(text: '完全中！我係咁', scores: {'Verify': 2}),
      AnswerOption(text: '有啲似，但唔完全', scores: {'Verify': 1}),
      AnswerOption(text: '有啲唔似', scores: {'Verify': -1}),
      AnswerOption(text: '完全唔係我', scores: {'Verify': -2}),
    ]),
    // ─── Clarifying questions when user rejects MBTI type ───
    const Question(id: 'clarity_ei', text: '你覺得自己偏向同人相處定係自己獨處多啲？', phase: AssessmentPhase.mbtiVerification, options: [
      AnswerOption(text: '同人一齊我會充電', scores: {'E': 3, 'Verify': 1}),
      AnswerOption(text: '一個人先係真正休息', scores: {'I': 3, 'Verify': 1}),
      AnswerOption(text: '兩樣都要，睇情況', scores: {'Verify': 1}),
    ]),
    const Question(id: 'clarity_sn', text: '你平時信直覺定信事實多啲？', phase: AssessmentPhase.mbtiVerification, options: [
      AnswerOption(text: '信事實數據同親眼所見', scores: {'S': 3, 'Verify': 1}),
      AnswerOption(text: '信直覺同可能性', scores: {'N': 3, 'Verify': 1}),
      AnswerOption(text: '兩樣都參考，但偏向事實', scores: {'S': 1, 'Verify': 1}),
    ]),
    const Question(id: 'clarity_tf', text: '做重要決定時，你用咩做首要考慮？', phase: AssessmentPhase.mbtiVerification, options: [
      AnswerOption(text: '邏輯同效率，結果最重要', scores: {'T': 3, 'Verify': 1}),
      AnswerOption(text: '人哋嘅感受同關係', scores: {'F': 3, 'Verify': 1}),
      AnswerOption(text: '兩樣都考慮，但偏向理性', scores: {'T': 1, 'Verify': 1}),
    ]),
    const Question(id: 'clarity_jp', text: '你鍾意計劃好定係隨心所欲？', phase: AssessmentPhase.mbtiVerification, options: [
      AnswerOption(text: '有計劃先安樂', scores: {'J': 3, 'Verify': 1}),
      AnswerOption(text: '隨心先自在', scores: {'P': 3, 'Verify': 1}),
      AnswerOption(text: '有大方向但留有彈性', scores: {'J': 1, 'P': 1, 'Verify': 1}),
    ]),

    // ═══ Phase 3: Enneagram ═══
    const Question(id: 'ennea_01', text: '你覺得自己最關注邊方面多啲？', phase: AssessmentPhase.enneagram, options: [
      AnswerOption(text: '人際關係同感受（關係最重要）', scores: {'Heart': 3, 'F': 1}),
      AnswerOption(text: '知識同安全感（明先安心）', scores: {'Head': 3, 'T': 1}),
      AnswerOption(text: '控制同自主（我自己話事）', scores: {'Gut': 3}),
    ]),
    const Question(id: 'ennea_02_heart', text: '喺關係入面，你最在意嘅係…', phase: AssessmentPhase.enneagram, condition: 'Heart>Head && Heart>Gut', options: [
      AnswerOption(text: '照顧到對方，對方需要我', scores: {'Heart': 2, 'F': 1, '2': 3}),
      AnswerOption(text: '對方欣賞我、認同我嘅價值', scores: {'Heart': 1, '3': 3}),
      AnswerOption(text: '對方真正了解我嘅獨特', scores: {'Heart': 2, '4': 3}),
    ]),
    const Question(id: 'ennea_02_head', text: '面對風險同未知，你通常…', phase: AssessmentPhase.enneagram, condition: 'Head>=Heart && Head>=Gut', options: [
      AnswerOption(text: '研究到最深入，準備好先行動', scores: {'Head': 2, 'T': 1, '5': 3}),
      AnswerOption(text: '諗定最差情況，做好後備方案', scores: {'Head': 2, '6': 3}),
      AnswerOption(text: '當係新機會，試咗先算', scores: {'Head': 1, '7': 3}),
    ]),
    const Question(id: 'ennea_02_gut', text: '你對自己嘅要求係…', phase: AssessmentPhase.enneagram, condition: 'Gut>=Heart && Gut>=Head', options: [
      AnswerOption(text: '一定要做啱，唔可以錯', scores: {'Gut': 2, 'J': 1, '1': 3}),
      AnswerOption(text: '唔鍾意被控制，我自己話事', scores: {'Gut': 2, '8': 3}),
      AnswerOption(text: '大家舒服就得，唔好搞咁多嘢', scores: {'Gut': 1, 'S': 1, '9': 3}),
    ]),
    const Question(id: 'ennea_03', text: '你覺得自己偏向…', phase: AssessmentPhase.enneagram, options: [
      AnswerOption(text: '多啲諗過去同細節', scores: {'S': 2, '6': 1}),
      AnswerOption(text: '多啲諗未來同可能性', scores: {'N': 2, '7': 1}),
      AnswerOption(text: '專注當下及時行樂', scores: {'P': 2, '8': 1}),
      AnswerOption(text: '專注原則同對錯', scores: {'J': 2, '1': 1}),
    ]),
    const Question(id: 'ennea_04', text: '壓力大嗰陣，你通常會…', phase: AssessmentPhase.enneagram, options: [
      AnswerOption(text: '不斷自我批評，覺得自己唔夠好', scores: {'1': 1, '4': 1}),
      AnswerOption(text: '收埋自己，唔想見人', scores: {'I': 1, '5': 1, '9': 1}),
      AnswerOption(text: '做更多嘢分散注意力', scores: {'3': 1, '7': 1}),
      AnswerOption(text: '好易發脾氣', scores: {'Gut': 1, '8': 2}),
    ]),

    // ═══ Phase 4: Enneagram Verification ═══
    const Question(id: 'verify_ennea', text: '你覺得自己係九型嘅 {TYPE} 型嗎？{TYPE_DESC}', phase: AssessmentPhase.enneagramVerification, customPrompt: '你覺得自己係九型嘅 {TYPE} 型嗎？{TYPE_DESC}', options: [
      AnswerOption(text: '好準確，係我嚟', scores: {'EVerify': 2}),
      AnswerOption(text: '有啲似，但不完全', scores: {'EVerify': 1}),
      AnswerOption(text: '有啲保留', scores: {'EVerify': -1}),
      AnswerOption(text: '完全唔係', scores: {'EVerify': -2}),
    ]),
  ];

  static const Map<int, String> _enneaDescs = {
    1: '（完美主義者·改革者）', 2: '（幫助者·給予者）', 3: '（成就者·表現者）',
    4: '（個人主義者·浪漫者）', 5: '（觀察者·思考者）', 6: '（忠誠者·疑惑者）',
    7: '（熱情者·享樂者）', 8: '（挑戰者·領袖者）', 9: '（和平者·調解者）',
  };

  int get answeredCount => state.history.length;
  int get totalEstimatedQuestions => 18;

  bool get hasMoreQuestions {
    if (state.phase == AssessmentPhase.result) return false;
    final path = _computePath();
    return state.currentQuestionIndex < path.length || _canAdvance();
  }

  Question getCurrentQuestion() {
    if (state.phase == AssessmentPhase.intro) {
      state.phase = AssessmentPhase.mbti;
      return _pool.firstWhere((q) => q.id == 'mbti_01');
    }
    if (state.phase == AssessmentPhase.result) {
      throw StateError('Assessment complete');
    }
    final path = _computePath();
    while (state.currentQuestionIndex >= path.length) {
      _advancePhase();
      if (state.phase == AssessmentPhase.result) break;
      // Recompute path for next phase
      final newPath = _computePath();
      if (newPath.isEmpty) { state.phase = AssessmentPhase.result; break; }
      return _fillTemplate(newPath[0]);
    }
    final q = _fillTemplate(path[state.currentQuestionIndex]);
    return q;
  }

  /// Submit a weighted multi-select answer.
  /// Each entry is (optionIndex, intensity) where intensity is 1–10.
  void submitAnswer(List<MapEntry<int, int>> selections) {
    final q = _fillTemplate(_computePath()[state.currentQuestionIndex]);

    // Compute weighted scores across all selected options
    final weightedScores = <String, int>{};
    final selectedTexts = <String>[];

    for (final entry in selections) {
      final optIndex = entry.key;
      final intensity = entry.value;
      final opt = q.options[optIndex];
      selectedTexts.add(opt.text);

      for (final s in opt.scores.entries) {
        weightedScores[s.key] =
            (weightedScores[s.key] ?? 0) + (s.value * intensity);
      }
    }

    state.applyScores(weightedScores);
    state.history.add(AnswerRecord(
      questionId: q.id,
      selections:
          selections.map((e) => WeightedSelection(optionIndex: e.key, intensity: e.value)).toList(),
      optionText: selectedTexts.join(' ｜ '),
      scores: Map.from(weightedScores),
    ));
    state.currentQuestionIndex++;
    _checkPhaseTransition();
  }

  Question _fillTemplate(Question q) {
    if (q.customPrompt == null) return q;
    final filled = q.customPrompt!
      .replaceAll('{MBTI}', state.mbtiString)
      .replaceAll('{TYPE}', state.leadingEnneaType.toString())
      .replaceAll('{TYPE_DESC}', _enneaDescs[state.leadingEnneaType] ?? '');
    return Question(id: q.id, text: filled, options: q.options, phase: q.phase);
  }

  List<Question> _computePath() {
    return _pool.where((q) {
      if (q.phase != state.phase) return false;
      if (q.condition == null) return true;
      return _eval(q.condition!);
    }).toList();
  }

  bool _eval(String cond) {
    try {
      final parts = cond.split(RegExp(r'[><=!&| ]+')).where((s) => s.isNotEmpty).toList();
      if (parts.length < 2) return true;
      final match = RegExp(r'[><=!]+').firstMatch(cond);
      final op = match?.group(0) ?? '>';
      final left = _score(parts[0]), right = _score(parts[1]);
      switch (op) {
        case '>': return left > right;
        case '>=': return left >= right;
        case '<': return left < right;
        case '<=': return left <= right;
        default: return true;
      }
    } catch (_) { return true; }
  }

  int _score(String dim) {
    switch (dim) {
      case 'E': return state.e; case 'I': return state.i;
      case 'S': return state.s; case 'N': return state.n;
      case 'T': return state.t; case 'F': return state.f;
      case 'J': return state.j; case 'P': return state.p;
      case 'Heart': return state.heart; case 'Head': return state.head;
      case 'Gut': return state.gut; default: return 0;
    }
  }

  bool _canAdvance() {
    switch (state.phase) {
      case AssessmentPhase.mbti: return state.history.length >= 6;
      case AssessmentPhase.mbtiVerification:
        return state.mbtiVerified || state.history.where((a) => a.questionId.startsWith('verify')).length >= 2;
      case AssessmentPhase.enneagram:
        return state.history.where((a) => a.questionId.startsWith('ennea')).length >= 4;
      case AssessmentPhase.enneagramVerification:
        return state.enneaVerified || state.history.where((a) => a.questionId.startsWith('verify_ennea')).length >= 1;
      default: return true;
    }
  }

  void _checkPhaseTransition() {
    final inPhase = state.history.where((a) => a.questionId.startsWith(
      state.phase == AssessmentPhase.mbti ? 'mbti' :
      state.phase == AssessmentPhase.mbtiVerification ? 'verify' :
      state.phase == AssessmentPhase.enneagram ? 'ennea' :
      'verify_ennea'
    )).length;

    // ─── MBTI Phase: minimum 8 questions before verification ───
    if (state.phase == AssessmentPhase.mbti && inPhase >= 8) {
      state.predictedMbti = state.mbtiString;
      _advancePhase();
    }
    // ─── MBTI Verification: handle "唔似" → targeted follow-up ───
    else if (state.phase == AssessmentPhase.mbtiVerification) {
      final lastAnswer = state.history.isNotEmpty ? state.history.last : null;
      final isRejected = lastAnswer != null &&
          lastAnswer.questionId == 'verify_mbti' &&
          (lastAnswer.scores.values.any((v) => v <= -1));

      if (isRejected && inPhase < 4) {
        // User said "唔似" — route to targeted follow-up questions instead of advancing
        // Stay in current phase, more targeted questions coming
        return;
      }
      if (state.mbtiVerified || inPhase >= 3) {
        _advancePhase();
      }
    }
    // ─── Enneagram Phase ───
    else if (state.phase == AssessmentPhase.enneagram && inPhase >= 4) {
      _advancePhase();
    }
    // ─── Enneagram Verification ───
    else if (state.phase == AssessmentPhase.enneagramVerification) {
      final lastAnswer = state.history.isNotEmpty ? state.history.last : null;
      final isRejected = lastAnswer != null &&
          lastAnswer.questionId.startsWith('verify_ennea') &&
          (lastAnswer.scores.values.any((v) => v <= -1));

      if (isRejected && inPhase < 3) {
        // User said "唔係" — targeted follow-up
        return;
      }
      if (state.enneaVerified || inPhase >= 2) {
        state.phase = AssessmentPhase.result;
      }
    }
  }

  void _advancePhase() {
    switch (state.phase) {
      case AssessmentPhase.mbti: state.phase = AssessmentPhase.mbtiVerification; break;
      case AssessmentPhase.mbtiVerification: state.phase = AssessmentPhase.enneagram; break;
      case AssessmentPhase.enneagram: state.phase = AssessmentPhase.enneagramVerification; break;
      case AssessmentPhase.enneagramVerification: state.phase = AssessmentPhase.result; break;
      default: break;
    }
    state.currentQuestionIndex = 0;
  }

  void reset() {
    state.e = state.i = state.s = state.n = state.t = state.f = state.j = state.p = 0;
    state.heart = state.head = state.gut = 0;
    for (int i = 0; i < 9; i++) state.enneaTypeScores[i] = 0;
    state.mbtiConfidence = state.enneaConfidence = 0;
    state.phase = AssessmentPhase.intro;
    state.currentQuestionIndex = 0;
    state.history.clear();
    state.predictedMbti = null;
  }

  /// Undo the last answer — restores previous state.
  /// Returns true if a question was undone, false if there's nothing to undo.
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
        case 'Heart': state.heart -= entry.value; break;
        case 'Head': state.head -= entry.value; break;
        case 'Gut': state.gut -= entry.value; break;
        case 'Verify': state.mbtiConfidence -= entry.value; break;
        case 'EVerify': state.enneaConfidence -= entry.value; break;
        default:
          final tn = int.tryParse(entry.key);
          if (tn != null && tn >= 1 && tn <= 9) {
            state.enneaTypeScores[tn - 1] -= entry.value;
          }
      }
    }

    // Restore phase to what it was before this answer
    // We need to find the phase of the previous question
    state.currentQuestionIndex = state.history.length;

    // Walk back through phases if we just cleared the last question of a phase
    _fixPhaseAfterGoBack();
    return true;
  }

  void _fixPhaseAfterGoBack() {
    if (state.history.isEmpty) {
      state.phase = AssessmentPhase.intro;
      return;
    }
    // Get the phase of the last remaining answer
    final lastQId = state.history.last.questionId;
    if (lastQId.startsWith('mbti_')) {
      state.phase = AssessmentPhase.mbti;
    } else if (lastQId.startsWith('verify') || lastQId.startsWith('clarity')) {
      state.phase = AssessmentPhase.mbtiVerification;
    } else if (lastQId.startsWith('ennea_')) {
      state.phase = AssessmentPhase.enneagram;
    } else if (lastQId.startsWith('verify_ennea')) {
      state.phase = AssessmentPhase.enneagramVerification;
    }
  }
}
