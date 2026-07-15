// ═══════════════════════════════════════════════════════════════════════
// PersonalityVerifier — Phase 2 & Phase 4 Mindset Verification
// MBTI + 九型人格 反向驗證引擎
// ═══════════════════════════════════════════════════════════════════════

import 'decision_state.dart';

/// Handles personality type verification — asking the user
/// to confirm/deny the system's tentative result, then routing
/// to fine-tuning or re-routing as needed.
class PersonalityVerifier {
  /// ─── MBTI VERIFICATION QUESTIONS ───
  /// Returns a verification question tailored to the tentative MBTI type

  DecisionQuestion getMbtiVerificationQuestion(String tentativeMBTI) {
    if (tentativeMBTI.isEmpty) {
      return _fallbackVerification();
    }

    final firstLetter = tentativeMBTI[0]; // E or I
    final lastLetter = tentativeMBTI[3]; // J or P

    // Route to the right verification bucket
    if (firstLetter == 'E' && lastLetter == 'J') {
      return _eJVerification(tentativeMBTI);
    } else if (firstLetter == 'E' && lastLetter == 'P') {
      return _ePVerification(tentativeMBTI);
    } else if (firstLetter == 'I' && lastLetter == 'J') {
      return _iJVerification(tentativeMBTI);
    } else {
      return _iPVerification(tentativeMBTI);
    }
  }

  DecisionQuestion _eJVerification(String type) {
    return DecisionQuestion(
      id: 'V_MBTI_EJ',
      phase: DecisionPhase.mbtiVerification,
      scenario: '根據你之前嘅答案，你似乎係「$type · 計劃型」嘅人。'
          '作為一個計劃型，你係咪覺得「冇plan就去玩」係好唔安樂？',
      options: [
        DecisionOption(
          text: '係！冇plan我會好焦慮，一定要plan好先',
          scores: {'V_confirm': 1.0, 'J': 0.5, 'enneagram_1': 0.3, 'enneagram_6': 0.2},
        ),
        DecisionOption(
          text: '有plan安心啲，但有時都會隨心',
          scores: {'V_adjust': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '唔係喎，我通常last minute先算，鍾意即興',
          scores: {'V_deny': 1.0, 'P': 0.5, 'enneagram_7': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['JP'],
      targetEnneagramTypes: [1, 6, 7, 9],
      phaseLabel: '驗證中…',
    );
  }

  DecisionQuestion _ePVerification(String type) {
    return DecisionQuestion(
      id: 'V_MBTI_EP',
      phase: DecisionPhase.mbtiVerification,
      scenario: '根據你之前嘅答案，你似乎係「$type · 靈活型」嘅人。'
          '作為一個靈活型，你係咪覺得「跟plan行」好局限？',
      options: [
        DecisionOption(
          text: '係！plan係用嚟打破㗎，最緊要靈活',
          scores: {'V_confirm': 1.0, 'P': 0.5, 'enneagram_7': 0.3, 'enneagram_9': 0.2},
        ),
        DecisionOption(
          text: '有plan都好，但可以改，唔使太死板',
          scores: {'V_adjust': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '我鍾意有計劃有結構，plan好先安樂',
          scores: {'V_deny': 1.0, 'J': 0.5, 'enneagram_1': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['JP'],
      targetEnneagramTypes: [1, 7, 9],
      phaseLabel: '驗證中…',
    );
  }

  DecisionQuestion _iJVerification(String type) {
    return DecisionQuestion(
      id: 'V_MBTI_IJ',
      phase: DecisionPhase.mbtiVerification,
      scenario: '根據你之前嘅答案，你似乎係「$type · 內斂有規劃」嘅人。'
          '作為一個內斂型，你係咪成日覺得「社交好消耗能量」？',
      options: [
        DecisionOption(
          text: '係！social完我會乾塘，一定要自己一個人叉電',
          scores: {'V_confirm': 1.0, 'I': 0.5, 'enneagram_5': 0.3, 'enneagram_9': 0.2},
        ),
        DecisionOption(
          text: '睇情況，同熟人就ok，同陌生人就攰',
          scores: {'V_adjust': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '我喺人堆充電㗎！越多人我越開心',
          scores: {'V_deny': 1.0, 'E': 0.5, 'enneagram_7': 0.3, 'enneagram_3': 0.2},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [5, 7, 9, 3],
      phaseLabel: '驗證中…',
    );
  }

  DecisionQuestion _iPVerification(String type) {
    return DecisionQuestion(
      id: 'V_MBTI_IP',
      phase: DecisionPhase.mbtiVerification,
      scenario: '根據你之前嘅答案，你似乎係「$type · 隨心自由型」嘅人。'
          '作為一個隨心型，你係咪好怕「被人管」或者「太多規則」？',
      options: [
        DecisionOption(
          text: '係！太多rule我會忟，俾我自由就得',
          scores: {'V_confirm': 1.0, 'P': 0.3, 'I': 0.3, 'enneagram_9': 0.3, 'enneagram_4': 0.2},
        ),
        DecisionOption(
          text: '有啲rule合理嘅都ok，但太多就唔得',
          scores: {'V_adjust': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '我鍾意有秩序有規則，跟規矩好重要',
          scores: {'V_deny': 1.0, 'J': 0.3, 'E': 0.2, 'enneagram_1': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['JP', 'EI'],
      targetEnneagramTypes: [1, 4, 9],
      phaseLabel: '驗證中…',
    );
  }

  DecisionQuestion _fallbackVerification() {
    return DecisionQuestion(
      id: 'V_MBTI_FALLBACK',
      phase: DecisionPhase.mbtiVerification,
      scenario: '初步分析你嘅答案，你覺得以下邊個形容最似你？',
      options: [
        DecisionOption(
          text: '我係一個外向有計劃嘅人',
          scores: {'V_confirm': 0.7, 'E': 0.3, 'J': 0.3},
        ),
        DecisionOption(
          text: '我係一個內斂隨心嘅人',
          scores: {'V_adjust': 0.5, 'I': 0.3, 'P': 0.3},
        ),
        DecisionOption(
          text: '我都唔肯定，覺得兩樣都有啲',
          scores: {'V_deny': 0.5},
        ),
      ],
      discriminationPower: 0.5,
      phaseLabel: '驗證中…',
    );
  }

  /// ─── ENNEAGRAM VERIFICATION QUESTIONS ───

  DecisionQuestion getEnneaVerificationQuestion(int primaryType) {
    switch (primaryType) {
      case 2:
        return _type2Verification();
      case 3:
        return _type3Verification();
      case 4:
        return _type4Verification();
      case 5:
        return _type5Verification();
      case 6:
        return _type6Verification();
      case 7:
        return _type7Verification();
      case 8:
        return _type8Verification();
      case 9:
        return _type9Verification();
      case 1:
        return _type1Verification();
      default:
        return _type5Verification();
    }
  }

  // ── Heart Center (2, 3, 4) ──

  DecisionQuestion _type2Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_2',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為2號助人者，你係咪成日覺得「人哋嘅需要比我自己重要」？',
      options: [
        DecisionOption(
          text: '係！成日唔記得自己，幫到人先覺得有價值',
          scores: {'V_confirm': 1.0, 'enneagram_2': 0.5, 'bias_emotional_suppress': 0.3},
        ),
        DecisionOption(
          text: '有時會，但我會平衡自己同人嘅需要',
          scores: {'V_adjust': 0.5, 'enneagram_2': 0.2, 'enneagram_9': 0.2},
        ),
        DecisionOption(
          text: '我其實好識say no，自己先係最重要',
          scores: {'V_deny': 1.0, 'enneagram_8': 0.3},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  DecisionQuestion _type3Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_3',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為3號成就者，你係咪好在意人哋點睇你、成唔成功？',
      options: [
        DecisionOption(
          text: '係！我好驚失敗俾人睇死，成就要俾人見到',
          scores: {'V_confirm': 1.0, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '在意但唔會過份，做好自己本份就夠',
          scores: {'V_adjust': 0.5, 'enneagram_3': 0.2, 'enneagram_1': 0.2},
        ),
        DecisionOption(
          text: '我其實好chill，唔care人點睇，最緊要自己開心',
          scores: {'V_deny': 1.0, 'enneagram_7': 0.3, 'enneagram_9': 0.2},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  DecisionQuestion _type4Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_4',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為4號個人主義者，你係咪覺得自己同好多人唔同、成日格格不入？',
      options: [
        DecisionOption(
          text: '係！成日覺得冇人明我，自己好獨特',
          scores: {'V_confirm': 1.0, 'enneagram_4': 0.5, 'bias_internal_attribution': 0.2},
        ),
        DecisionOption(
          text: '有啲位係，但我都融入到大眾，唔會太極端',
          scores: {'V_adjust': 0.5, 'enneagram_4': 0.2, 'enneagram_9': 0.2},
        ),
        DecisionOption(
          text: '我覺得自己好普通，同其他人冇咩分別',
          scores: {'V_deny': 1.0, 'enneagram_9': 0.3},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  // ── Head Center (5, 6, 7) ──

  DecisionQuestion _type5Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_5',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為5號觀察者，你係咪覺得「知得夠多先安全」？',
      options: [
        DecisionOption(
          text: '係！我唔會講冇把握嘅嘢，要研究清楚先安心',
          scores: {'V_confirm': 1.0, 'enneagram_5': 0.5, 'bias_catastrophizing': 0.2},
        ),
        DecisionOption(
          text: '我鍾意research，但夠用就得，唔使去到盡',
          scores: {'V_adjust': 0.5, 'enneagram_5': 0.2, 'enneagram_6': 0.2},
        ),
        DecisionOption(
          text: '我通常靠直覺行動，唔會諗太多',
          scores: {'V_deny': 1.0, 'enneagram_7': 0.3, 'enneagram_8': 0.2},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  DecisionQuestion _type6Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_6',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為6號忠誠者，你係咪成日諗「最壞情況」？',
      options: [
        DecisionOption(
          text: '係！我會先預備晒所有意外，plan B plan C',
          scores: {'V_confirm': 1.0, 'enneagram_6': 0.5, 'bias_catastrophizing': 0.3},
        ),
        DecisionOption(
          text: '有時會諗，但唔會太誇張，適量準備就夠',
          scores: {'V_adjust': 0.5, 'enneagram_6': 0.2, 'enneagram_1': 0.2},
        ),
        DecisionOption(
          text: '我通常好樂觀，船到橋頭自然直，擔心咁多做咩',
          scores: {'V_deny': 1.0, 'enneagram_7': 0.3},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  DecisionQuestion _type7Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_7',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為7號熱情者，你係咪最怕悶同被困住？',
      options: [
        DecisionOption(
          text: '係！冇選擇、被困住係我最怕嘅事，我要自由',
          scores: {'V_confirm': 1.0, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '我鍾意多選擇，但都可以專注做一件事',
          scores: {'V_adjust': 0.5, 'enneagram_7': 0.2, 'enneagram_9': 0.2},
        ),
        DecisionOption(
          text: '我可以好專注做一件事好耐，唔怕悶',
          scores: {'V_deny': 1.0, 'enneagram_5': 0.3, 'enneagram_1': 0.2},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  // ── Gut Center (8, 9, 1) ──

  DecisionQuestion _type8Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_8',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為8號挑戰者，你係咪覺得「弱者會被人欺負，所以要強」？',
      options: [
        DecisionOption(
          text: '係！我要保護自己同身邊人，唔可以俾人睇小',
          scores: {'V_confirm': 1.0, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '我強勢但都注重公平，唔會欺負人',
          scores: {'V_adjust': 0.5, 'enneagram_8': 0.2, 'enneagram_1': 0.2},
        ),
        DecisionOption(
          text: '我其實好隨和，唔會同人爭，和平最重要',
          scores: {'V_deny': 1.0, 'enneagram_9': 0.3, 'enneagram_2': 0.2},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  DecisionQuestion _type9Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_9',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為9號調和者，你係咪成日為咗和諧而收埋自己感受？',
      options: [
        DecisionOption(
          text: '係！我好怕衝突，寧願自己吞咗佢，費事搞大件事',
          scores: {'V_confirm': 1.0, 'enneagram_9': 0.5, 'bias_emotional_suppress': 0.3},
        ),
        DecisionOption(
          text: '有時會，但我都會表達自己意見，唔會完全收埋',
          scores: {'V_adjust': 0.5, 'enneagram_9': 0.2, 'enneagram_2': 0.2},
        ),
        DecisionOption(
          text: '我有咩就直接講，唔收埋，衝突都唔怕',
          scores: {'V_deny': 1.0, 'enneagram_8': 0.3, 'enneagram_4': 0.2},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  DecisionQuestion _type1Verification() {
    return DecisionQuestion(
      id: 'V_ENNEA_1',
      phase: DecisionPhase.enneaVerification,
      scenario: '作為1號完美主義者，你係咪對自己同人哋都好有要求？',
      options: [
        DecisionOption(
          text: '係！我覺得做就應該做到最好，標準唔可以低',
          scores: {'V_confirm': 1.0, 'enneagram_1': 0.5, 'bias_internal_attribution': 0.2},
        ),
        DecisionOption(
          text: '我有標準但都接受人唔完美，盡力就得',
          scores: {'V_adjust': 0.5, 'enneagram_1': 0.2, 'enneagram_9': 0.2},
        ),
        DecisionOption(
          text: '我其實好隨意，是但啦，最緊要開心',
          scores: {'V_deny': 1.0, 'enneagram_7': 0.3, 'enneagram_9': 0.2},
        ),
      ],
      discriminationPower: 0.9,
      phaseLabel: '最終驗證…',
    );
  }

  /// ─── VERIFICATION HANDLING ───

  /// Determine answer code from V-prefixed scores
  /// Returns 'A' (confirm), 'B' (adjust), or 'C' (deny/reroute)
  static String classifyVerificationAnswer(Map<String, double> scores) {
    final confirm = scores['V_confirm'] ?? 0;
    final adjust = scores['V_adjust'] ?? 0;
    final deny = scores['V_deny'] ?? 0;

    if (confirm >= deny && confirm >= adjust) return 'A';
    if (adjust >= confirm && adjust >= deny) return 'B';
    return 'C';
  }
}
