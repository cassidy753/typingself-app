// ═══════════════════════════════════════════════════════════════════════
// QuestionBank — 50+ HK Situational Cantonese Questions
// MBTI × 九型人格 雙重編碼 Decision Tree 題庫
// ═══════════════════════════════════════════════════════════════════════

import 'decision_state.dart';

/// Complete question bank for the v2 Decision Tree engine.
/// All questions in HK Cantonese with double-dip scoring.
class QuestionBank {
  final Map<String, DecisionQuestion> _questions = {};

  QuestionBank() {
    _initAllQuestions();
  }

  /// Get a question by ID
  DecisionQuestion getQuestion(String id) {
    if (_questions.containsKey(id)) return _questions[id]!;
    return _getFallback();
  }

  /// Get last question (safety fallback)
  DecisionQuestion getLastQuestion() => _questions.values.last;

  /// Access all questions
  List<DecisionQuestion> get allQuestions => _questions.values.toList();

  DecisionQuestion _getFallback() {
    return DecisionQuestion(
      id: 'FALLBACK',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你覺得自己係一個咩嘢人？',
      options: [
        DecisionOption(text: '外向、鍾意同人一齊', scores: {'E': 1.0, 'enneagram_7': 0.5}),
        DecisionOption(text: '內向、需要自己空間', scores: {'I': 1.0, 'enneagram_5': 0.5}),
        DecisionOption(text: '理性、講邏輯', scores: {'T': 0.5, 'enneagram_1': 0.5}),
        DecisionOption(text: '感性、重視感受', scores: {'F': 0.5, 'enneagram_4': 0.5}),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PHASE 1: MBTI ROUTING QUESTIONS (Q1-Q6 + dynamic variants)
  // ═══════════════════════════════════════════════════════════════════════

  void _initAllQuestions() {
    // ─── Q1: E/I Screening (all users start here) ───
    _questions['DQ_EI_01'] = DecisionQuestion(
      id: 'DQ_EI_01',
      phase: DecisionPhase.mbtiRouting,
      scenario: '星期五收工好攰，聽日放假，你諗住…',
      options: [
        DecisionOption(
          text: '約朋友出街食飯吹水，難得放假嘛',
          scores: {'E': 2.0, 'enneagram_7': 1.0, 'enneagram_3': 0.5, 'health_positive': 0.05},
        ),
        DecisionOption(
          text: '留喺屋企攤屍乜都唔做，me time最緊要',
          scores: {'I': 2.0, 'enneagram_9': 1.0, 'enneagram_5': 0.5},
        ),
        DecisionOption(
          text: 'plan定聽日嘅行程，唔可以浪費假期',
          scores: {'J': 1.0, 'I': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '睇吓朋友有冇約，有人約就出去冇人就hea',
          scores: {'E': 1.0, 'P': 0.5, 'enneagram_9': 0.5, 'enneagram_7': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [7, 9, 5, 3, 1, 6],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q2a: E-path (T/F + J/P for Extroverts) ───
    _questions['DQ_TFJP_E'] = DecisionQuestion(
      id: 'DQ_TFJP_E',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你約咗朋友去茶餐廳，朋友遲到半個鐘，你會…',
      options: [
        DecisionOption(
          text: 'WhatsApp追佢話「我聽日要早起身㗎，快啲啦」',
          scores: {'J': 1.0, 'T': 1.0, 'enneagram_1': 1.0, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '唔緊要，順便睇menu諗食咩，悠閒等',
          scores: {'P': 1.0, 'F': 0.5, 'enneagram_9': 1.0, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '分析係咪塞車，計佢大約幾時到，等陣冇問題',
          scores: {'T': 1.0, 'P': 0.5, 'enneagram_5': 1.0, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '打俾佢問使唔使去接佢，怕佢有咩事',
          scores: {'F': 1.0, 'E': 0.5, 'enneagram_2': 1.0},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['TF', 'JP'],
      targetEnneagramTypes: [1, 9, 5, 2, 6, 7],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q2b: I-path (T/F + J/P for Introverts) ───
    _questions['DQ_TFJP_I'] = DecisionQuestion(
      id: 'DQ_TFJP_I',
      phase: DecisionPhase.mbtiRouting,
      scenario: '終於有珍貴嘅me time，你會點用？',
      options: [
        DecisionOption(
          text: 'plan定下星期to-do list，順便執屋整理',
          scores: {'J': 1.0, 'T': 0.5, 'enneagram_1': 1.0, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '煲劇打機，隨心所欲，唔諗其他嘢',
          scores: {'P': 1.0, 'S': 0.5, 'enneagram_7': 1.0, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '睇書/學新嘢，趁冇人騷擾專注研究',
          scores: {'T': 1.0, 'I': 0.5, 'enneagram_5': 1.0, 'enneagram_4': 0.3},
        ),
        DecisionOption(
          text: '寫日記/反思近日發生嘅事，整理感受',
          scores: {'F': 1.0, 'I': 0.5, 'enneagram_4': 1.0, 'enneagram_9': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['TF', 'JP'],
      targetEnneagramTypes: [1, 7, 5, 4, 9, 3],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q3: S/N Confirmation ───
    _questions['DQ_SN_03'] = DecisionQuestion(
      id: 'DQ_SN_03',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你同friend planning去旅行，friend話「是但啦你決定」，你會…',
      options: [
        DecisionOption(
          text: '上網搵晒行程交通餐廳，整Excel itinerary俾佢',
          scores: {'S': 1.0, 'J': 1.0, 'enneagram_1': 1.0, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '問清楚「你鍾意沙灘定城市？美食定風景？」逐步縮窄',
          scores: {'N': 1.0, 'F': 0.5, 'enneagram_4': 1.0, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '打開Google Maps隨心揀，去到再算啦',
          scores: {'P': 1.0, 'N': 0.5, 'enneagram_7': 1.0, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '直接揀個最穩陣option — 東京/台北，費事煩',
          scores: {'S': 1.0, 'T': 0.5, 'enneagram_6': 1.0, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['SN', 'JP'],
      targetEnneagramTypes: [1, 4, 7, 6, 9, 3],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q4: Dynamic Uncertainty (EI) ───
    _questions['DQ_EI_UNCERTAIN'] = DecisionQuestion(
      id: 'DQ_EI_UNCERTAIN',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你要去一個新地方（例如新商場/新公司），你會…',
      options: [
        DecisionOption(
          text: '約人一齊去，沿途有傾有講，唔怕蕩失',
          scores: {'E': 1.5, 'enneagram_7': 0.5, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '自己Google Maps睇定先去，唔使人陪',
          scores: {'I': 1.5, 'enneagram_5': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '去到再問路人/睇指示牌，冒險都幾好玩',
          scores: {'P': 0.5, 'S': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: 'research定晒先，唔鍾意有意外',
          scores: {'J': 0.5, 'enneagram_6': 0.5, 'enneagram_1': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [7, 2, 5, 6, 1],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q4: Dynamic Uncertainty (TF) ───
    _questions['DQ_TF_UNCERTAIN'] = DecisionQuestion(
      id: 'DQ_TF_UNCERTAIN',
      phase: DecisionPhase.mbtiRouting,
      scenario: '同事做錯嘢俾老細大鬧，你會…',
      options: [
        DecisionOption(
          text: '分析錯喺邊、點解會發生、下次點避免',
          scores: {'T': 1.5, 'enneagram_1': 0.5, 'enneagram_5': 0.5, 'bias_internal_attribution': 0.2},
        ),
        DecisionOption(
          text: '私下安慰佢，請佢食lunch等佢開心返',
          scores: {'F': 1.5, 'enneagram_2': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '覺得老細太惡，幫同事講返兩句好說話',
          scores: {'F': 1.0, 'E': 0.5, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '唔關我事，靜靜做返自己嘢',
          scores: {'T': 1.0, 'I': 0.5, 'enneagram_5': 0.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['TF'],
      targetEnneagramTypes: [1, 5, 2, 9, 8],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q4: Dynamic Uncertainty (JP) ───
    _questions['DQ_JP_UNCERTAIN'] = DecisionQuestion(
      id: 'DQ_JP_UNCERTAIN',
      phase: DecisionPhase.mbtiRouting,
      scenario: 'MTR迫到爆，你會…',
      options: [
        DecisionOption(
          text: '睇住時間計幾點到，plan定落車行快啲',
          scores: {'J': 1.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '戴headphone聽歌，自己世界，遲到就算啦',
          scores: {'P': 1.5, 'enneagram_9': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '早啲出門避開人潮，唔鍾意迫',
          scores: {'J': 1.0, 'enneagram_6': 0.5, 'enneagram_5': 0.5},
        ),
        DecisionOption(
          text: '睇下其他人做咩，觀察人類幾有趣',
          scores: {'N': 0.5, 'enneagram_4': 0.5, 'enneagram_5': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['JP'],
      targetEnneagramTypes: [1, 6, 9, 7, 5, 4],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q4: Dynamic Uncertainty (SN) ───
    _questions['DQ_SN_UNCERTAIN'] = DecisionQuestion(
      id: 'DQ_SN_UNCERTAIN',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你睇新聞focus喺…',
      options: [
        DecisionOption(
          text: '具體發生咗咩事、幾時、邊度、邊個做',
          scores: {'S': 1.5, 'enneagram_6': 0.5, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '呢件事代表咩趨勢、會點影響將來',
          scores: {'N': 1.5, 'enneagram_5': 0.5, 'enneagram_4': 0.5},
        ),
        DecisionOption(
          text: '邊啲人受影響、佢哋感受係點',
          scores: {'F': 0.5, 'enneagram_2': 0.5, 'enneagram_4': 0.5},
        ),
        DecisionOption(
          text: '呢單新聞有冇啲咩可以學到',
          scores: {'N': 1.0, 'T': 0.5, 'enneagram_5': 0.5, 'enneagram_3': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetDimensions: ['SN'],
      targetEnneagramTypes: [6, 1, 5, 4, 2, 3],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q5: Compound (Universal Key) ───
    _questions['DQ_MULTI_05'] = DecisionQuestion(
      id: 'DQ_MULTI_05',
      phase: DecisionPhase.mbtiRouting,
      scenario: '阿媽話你「做咩唔拍拖」，你會…',
      options: [
        DecisionOption(
          text: '解釋我嘅人生規劃俾佢聽，等佢放心',
          scores: {'T': 1.0, 'J': 1.0, 'enneagram_1': 1.0, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '「吓咩呀得啦得啦」hea過去',
          scores: {'P': 0.5, 'S': 0.5, 'enneagram_9': 1.0, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '「你都唔明我㗎」覺得佢唔了解你',
          scores: {'F': 1.0, 'I': 0.5, 'enneagram_4': 1.0, 'bias_internal_attribution': 0.3},
        ),
        DecisionOption(
          text: '「介紹幾個女仔俾我啦！」即刻叫阿媽幫手',
          scores: {'E': 1.0, 'enneagram_7': 1.0, 'enneagram_3': 0.5},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['EI', 'SN', 'TF', 'JP'],
      targetEnneagramTypes: [1, 9, 4, 7, 3],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Q6: Final Clarification ───
    _questions['DQ_FINAL_06'] = DecisionQuestion(
      id: 'DQ_FINAL_06',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你返工OT到好攰，但project deadline聽日，你會…',
      options: [
        DecisionOption(
          text: '頂硬上做完佢，唔可以miss deadline',
          scores: {'J': 2.0, 'T': 1.0, 'enneagram_3': 1.0, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '同老細傾可唔可以延遲，解釋情況',
          scores: {'F': 1.0, 'enneagram_9': 1.0, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '放低一陣，抖完再做好過夾硬嚟',
          scores: {'P': 1.0, 'enneagram_9': 0.5, 'enneagram_7': 0.5, 'health_positive': 0.05},
        ),
        DecisionOption(
          text: '搵同事幫手，唔怕麻煩人',
          scores: {'E': 1.0, 'enneagram_2': 1.0, 'enneagram_3': 0.5},
        ),
      ],
      discriminationPower: 0.9,
      targetDimensions: ['EI', 'TF', 'JP'],
      targetEnneagramTypes: [3, 1, 9, 2, 7],
      phaseLabel: 'MBTI判定中…',
    );

    // ═════════════════════════════════════════════════════════════════════
    // BONUS PHASE 1 QUESTIONS (for deeper uncertainty resolution)
    // ═════════════════════════════════════════════════════════════════════

    _questions['DQ_EI_BONUS_1'] = DecisionQuestion(
      id: 'DQ_EI_BONUS_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你去party/聚會，通常你係…',
      options: [
        DecisionOption(
          text: '主動social走勻全場，邊個都傾兩句',
          scores: {'E': 2.0, 'enneagram_3': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '留喺角落同熟嘅人傾，唔會主動識人',
          scores: {'I': 2.0, 'enneagram_5': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '睇情況，有氣氛就玩冇氣氛就早走',
          scores: {'P': 0.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.75,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [3, 7, 5, 9],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_TF_BONUS_1'] = DecisionQuestion(
      id: 'DQ_TF_BONUS_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '朋友同你講佢最近失戀，你第一句會講…',
      options: [
        DecisionOption(
          text: '「佢配唔起你㗎，下個會更好」— 分析問題',
          scores: {'T': 1.5, 'enneagram_1': 0.5, 'enneagram_5': 0.5},
        ),
        DecisionOption(
          text: '「我好明白你感受，喊出嚟啦」— 情感支持',
          scores: {'F': 1.5, 'enneagram_2': 0.5, 'enneagram_4': 0.5},
        ),
        DecisionOption(
          text: '靜靜聽佢講，唔使俾意見',
          scores: {'F': 1.0, 'I': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '約佢出嚟玩等佢忘記傷心',
          scores: {'E': 0.5, 'enneagram_7': 0.5, 'enneagram_2': 0.5},
        ),
      ],
      discriminationPower: 0.75,
      targetDimensions: ['TF'],
      targetEnneagramTypes: [1, 5, 2, 4, 9, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_SN_BONUS_1'] = DecisionQuestion(
      id: 'DQ_SN_BONUS_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你行街見到一件好靚嘅衫，你第一時間諗咩？',
      options: [
        DecisionOption(
          text: '幾錢、咩質地、襟唔襟着、值唔值',
          scores: {'S': 1.5, 'T': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '如果我着住佢去XX場合會係咩感覺',
          scores: {'N': 1.5, 'F': 0.5, 'enneagram_4': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '即刻試吓先，鍾意就買',
          scores: {'P': 0.5, 'enneagram_7': 0.5},
        ),
      ],
      discriminationPower: 0.75,
      targetDimensions: ['SN'],
      targetEnneagramTypes: [1, 6, 4, 3, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_JP_BONUS_1'] = DecisionQuestion(
      id: 'DQ_JP_BONUS_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你個衣櫃係…',
      options: [
        DecisionOption(
          text: '整整齊齊，分門別類，顏色排列',
          scores: {'J': 1.5, 'S': 0.5, 'enneagram_1': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '亂中有序，搵到嘢就得啦',
          scores: {'P': 1.5, 'enneagram_9': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '會整理但唔會太 extreme，舒服就好',
          scores: {'J': 0.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['JP'],
      targetEnneagramTypes: [1, 3, 9, 7],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── Additional HK situational questions ───
    _questions['DQ_HK_SOCIAL_1'] = DecisionQuestion(
      id: 'DQ_HK_SOCIAL_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '茶餐廳阿姐落錯單，你會…',
      options: [
        DecisionOption(
          text: '即刻同佢講「我嗌嘅係凍奶茶喎」',
          scores: {'T': 0.5, 'J': 0.5, 'enneagram_1': 0.5, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '是但啦，照飲熱奶茶，費事麻煩人',
          scores: {'P': 0.5, 'F': 0.5, 'enneagram_9': 1.0, 'bias_emotional_suppress': 0.2},
        ),
        DecisionOption(
          text: '望住杯茶諗緊講唔講好，最後都冇出聲',
          scores: {'I': 0.5, 'F': 0.5, 'enneagram_9': 0.5, 'enneagram_4': 0.5},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['EI', 'TF', 'JP'],
      targetEnneagramTypes: [1, 8, 9, 4],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_WORK_1'] = DecisionQuestion(
      id: 'DQ_HK_WORK_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '老細話「呢個project你負責」，你第一個反應係…',
      options: [
        DecisionOption(
          text: '好呀！我會plan好晒俾你睇',
          scores: {'E': 0.5, 'J': 0.5, 'enneagram_3': 0.5, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '心諗「死啦」但係會應承然後慢慢搞',
          scores: {'I': 0.5, 'enneagram_6': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '評估下要咩資源、幾耐、難唔難做',
          scores: {'T': 0.5, 'enneagram_5': 0.5, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '開心有新挑戰，即刻開工',
          scores: {'E': 0.5, 'P': 0.5, 'enneagram_7': 0.5},
        ),
      ],
      discriminationPower: 0.75,
      targetDimensions: ['EI', 'TF', 'JP'],
      targetEnneagramTypes: [3, 8, 6, 9, 5, 1, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_FOOD_1'] = DecisionQuestion(
      id: 'DQ_HK_FOOD_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '同班friend食飯諗食咩，你會…',
      options: [
        DecisionOption(
          text: '直接提案「食XX啦，我食過好食」',
          scores: {'E': 0.5, 'J': 0.5, 'enneagram_8': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '「是但啦，你哋決定」唔想出主意',
          scores: {'P': 0.5, 'enneagram_9': 1.0, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '逐間分析好壞，俾大家揀',
          scores: {'T': 0.5, 'N': 0.5, 'enneagram_5': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '提議「不如試新嘢」冒險下',
          scores: {'P': 0.5, 'N': 0.5, 'enneagram_7': 0.5},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['EI', 'TF', 'JP', 'SN'],
      targetEnneagramTypes: [8, 3, 9, 2, 5, 6, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_MONEY_1'] = DecisionQuestion(
      id: 'DQ_HK_MONEY_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '出咗bonus，你會點用？',
      options: [
        DecisionOption(
          text: '儲起佢，plan吓點投資',
          scores: {'J': 0.5, 'T': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '獎勵自己，買嘢/去旅行開心下',
          scores: {'P': 0.5, 'enneagram_7': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '請屋企人朋友食飯，開心share',
          scores: {'F': 0.5, 'enneagram_2': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '用嚟學新嘢/報course投資自己',
          scores: {'N': 0.5, 'enneagram_5': 0.5, 'enneagram_4': 0.5},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['JP', 'TF', 'SN'],
      targetEnneagramTypes: [1, 6, 7, 3, 2, 9, 5, 4],
      phaseLabel: 'MBTI判定中…',
    );

    // ─── ROUTING: E/I Re-check (for verification C) ───
    _questions['DQ_RR_EI'] = DecisionQuestion(
      id: 'DQ_RR_EI',
      phase: DecisionPhase.mbtiReRouting,
      scenario: '你覺得邊個形容更似你？',
      options: [
        DecisionOption(
          text: '我鍾意同人一齊，從人嗰度攞energy',
          scores: {'E': 2.0, 'enneagram_7': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '我自己一個人先叉到電，社交係消耗',
          scores: {'I': 2.0, 'enneagram_5': 0.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.9,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [7, 3, 5, 9],
      phaseLabel: '重新分析…',
    );

    _questions['DQ_RR_E_PATH'] = DecisionQuestion(
      id: 'DQ_RR_E_PATH',
      phase: DecisionPhase.mbtiReRouting,
      scenario: '你喺party入面多數係…',
      options: [
        DecisionOption(
          text: '主動social嗰個，帶動氣氛',
          scores: {'E': 1.5, 'enneagram_7': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '同熟人圍埋傾計，唔會主動識新朋友',
          scores: {'I': 0.5, 'enneagram_9': 0.5, 'enneagram_5': 0.5},
        ),
        DecisionOption(
          text: '睇情況，有feel會玩好癲',
          scores: {'P': 0.5, 'enneagram_7': 0.5},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [7, 3, 9, 5],
      phaseLabel: '重新分析…',
    );

    _questions['DQ_RR_I_PATH'] = DecisionQuestion(
      id: 'DQ_RR_I_PATH',
      phase: DecisionPhase.mbtiReRouting,
      scenario: '你放假prefer…',
      options: [
        DecisionOption(
          text: '約人出街，有人陪先開心',
          scores: {'E': 1.5, 'enneagram_7': 0.5, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '留喺屋企做自己嘢，me time先係享受',
          scores: {'I': 1.5, 'enneagram_5': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '出街但自己一個人行，都ok',
          scores: {'I': 0.5, 'enneagram_4': 0.5, 'enneagram_5': 0.5},
        ),
      ],
      discriminationPower: 0.85,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [7, 2, 5, 9, 4],
      phaseLabel: '重新分析…',
    );

    // ─── Fine-tuning question ───
    _questions['DQ_FT_JP'] = DecisionQuestion(
      id: 'DQ_FT_JP',
      phase: DecisionPhase.mbtiFineTuning,
      scenario: '你覺得自己更接近邊種人？',
      options: [
        DecisionOption(
          text: '我鍾意有計劃、有結構嘅生活，安心啲',
          scores: {'J': 2.0, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '我隨心所欲、鍾意即興，plan咗都會改',
          scores: {'P': 2.0, 'enneagram_7': 0.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.9,
      targetDimensions: ['JP'],
      targetEnneagramTypes: [1, 6, 7, 9],
      phaseLabel: '微調中…',
    );

    // ═════════════════════════════════════════════════════════════════════
    // PHASE 3a: ENNEAGRAM CENTER SCREENING
    // ═════════════════════════════════════════════════════════════════════

    _questions['DQ_ENNEA_3CENTER'] = DecisionQuestion(
      id: 'DQ_ENNEA_3CENTER',
      phase: DecisionPhase.enneaCenter,
      scenario: '你覺得人生最緊要係…',
      options: [
        DecisionOption(
          text: '被愛同有意義嘅關係 — 人同人之間嘅連結',
          scores: {'enneagram_2': 0.5, 'enneagram_3': 0.5, 'enneagram_4': 0.5, 'F': 0.5},
        ),
        DecisionOption(
          text: '安全同明白呢個世界 — 知多啲先安心',
          scores: {'enneagram_5': 0.5, 'enneagram_6': 0.5, 'enneagram_7': 0.5, 'T': 0.5},
        ),
        DecisionOption(
          text: '自主同捍衛自己立場 — 唔可以俾人恰',
          scores: {'enneagram_8': 0.5, 'enneagram_9': 0.5, 'enneagram_1': 0.5, 'J': 0.5},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [2, 3, 4, 5, 6, 7, 8, 9, 1],
      phaseLabel: '九型分析中…',
    );

    // ═════════════════════════════════════════════════════════════════════
    // PHASE 3b: CENTER-SPECIFIC DEEP QUESTIONS
    // ═════════════════════════════════════════════════════════════════════

    // ── Heart Center (2, 3, 4) ──
    _questions['DQ_ENNEA_HEART'] = DecisionQuestion(
      id: 'DQ_ENNEA_HEART',
      phase: DecisionPhase.enneaDeep,
      scenario: '你幫咗朋友一個大忙，佢多謝你，你心裡面咩感覺？',
      options: [
        DecisionOption(
          text: '開心 — 好enjoy幫到人嘅感覺，呢個就係我',
          scores: {'enneagram_2': 2.0, 'F': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '覺得自己幾有能力，辦到件事證明到自己',
          scores: {'enneagram_3': 2.0, 'T': 0.3, 'enneagram_1': 0.3},
        ),
        DecisionOption(
          text: '覺得…其實佢明唔明我用心良苦？有啲複雜',
          scores: {'enneagram_4': 2.0, 'F': 0.5, 'bias_internal_attribution': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [2, 3, 4],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_HEART_2'] = DecisionQuestion(
      id: 'DQ_ENNEA_HEART_2',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得自己嘅價值來自…',
      options: [
        DecisionOption(
          text: '被需要同幫到人 — 有人需要我先有意義',
          scores: {'enneagram_2': 1.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '成就同達到目標 — 成功俾人睇到',
          scores: {'enneagram_3': 1.5, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '忠於自己同獨特性 — 我唔想同人一樣',
          scores: {'enneagram_4': 1.5, 'enneagram_5': 0.3, 'bias_internal_attribution': 0.2},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [2, 3, 4],
      phaseLabel: '九型深入分析…',
    );

    // ── Head Center (5, 6, 7) ──
    _questions['DQ_ENNEA_HEAD'] = DecisionQuestion(
      id: 'DQ_ENNEA_HEAD',
      phase: DecisionPhase.enneaDeep,
      scenario: '你面對一個重大決定，你會…',
      options: [
        DecisionOption(
          text: '搜集晒所有資料先敢決定，要知晒先安心',
          scores: {'enneagram_5': 2.0, 'T': 0.5, 'enneagram_1': 0.3},
        ),
        DecisionOption(
          text: '列晒好壞處，問信任嘅人意見，唔敢自己決定',
          scores: {'enneagram_6': 2.0, 'enneagram_1': 0.3, 'bias_catastrophizing': 0.2},
        ),
        DecisionOption(
          text: '隨心啦，諗太多冇用，最緊要開心',
          scores: {'enneagram_7': 2.0, 'P': 0.5, 'enneagram_9': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [5, 6, 7],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_HEAD_2'] = DecisionQuestion(
      id: 'DQ_ENNEA_HEAD_2',
      phase: DecisionPhase.enneaDeep,
      scenario: '你得閒一個人在屋企，你最鍾意做咩？',
      options: [
        DecisionOption(
          text: '睇書/上網研究有興趣嘅topic，學到新嘢好開心',
          scores: {'enneagram_5': 1.5, 'enneagram_4': 0.3},
        ),
        DecisionOption(
          text: 'check下有冇嘢漏咗/plan吓未來，安心啲',
          scores: {'enneagram_6': 1.5, 'enneagram_1': 0.5, 'bias_catastrophizing': 0.2},
        ),
        DecisionOption(
          text: '開Netflix/打機，搵嘢開心下，最怕悶',
          scores: {'enneagram_7': 1.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [5, 6, 7],
      phaseLabel: '九型深入分析…',
    );

    // ── Gut Center (8, 9, 1) ──
    _questions['DQ_ENNEA_GUT'] = DecisionQuestion(
      id: 'DQ_ENNEA_GUT',
      phase: DecisionPhase.enneaDeep,
      scenario: '你同人有衝突，你多數係…',
      options: [
        DecisionOption(
          text: '直接企出嚟，唔會退讓，我要話俾人知我底線',
          scores: {'enneagram_8': 2.0, 'E': 0.5, 'enneagram_3': 0.3},
        ),
        DecisionOption(
          text: '息事寧人，費事嘈，忍吓就過去㗎啦',
          scores: {'enneagram_9': 2.0, 'I': 0.5, 'bias_emotional_suppress': 0.3},
        ),
        DecisionOption(
          text: '講道理，要分出對錯，唔可以馬虎了事',
          scores: {'enneagram_1': 2.0, 'T': 0.5, 'enneagram_6': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [8, 9, 1],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_GUT_2'] = DecisionQuestion(
      id: 'DQ_ENNEA_GUT_2',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得「公平」係…',
      options: [
        DecisionOption(
          text: '要自己爭取返嚟，冇人會俾你，唔可以蝕底',
          scores: {'enneagram_8': 1.5, 'enneagram_7': 0.3, 'enneagram_3': 0.3},
        ),
        DecisionOption(
          text: '大家開心就好，有時讓步都係一種公平',
          scores: {'enneagram_9': 1.5, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '跟規矩辦事，對錯分明，標準要一致',
          scores: {'enneagram_1': 1.5, 'enneagram_6': 0.5},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [8, 9, 1],
      phaseLabel: '九型深入分析…',
    );

    // ─── Additional center depth questions ───
    _questions['DQ_ENNEA_ALL_1'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_1',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得自己最大嘅弱點係…',
      options: [
        DecisionOption(
          text: '太在意人哋點睇我，成日忽略自己 needs',
          scores: {'enneagram_2': 0.5, 'enneagram_3': 0.5, 'enneagram_4': 0.5},
        ),
        DecisionOption(
          text: '太 analysis paralysis，諗太多做唔到決定',
          scores: {'enneagram_5': 0.5, 'enneagram_6': 0.5, 'enneagram_1': 0.3},
        ),
        DecisionOption(
          text: '太怕衝突，成日收埋自己感受',
          scores: {'enneagram_9': 0.5, 'enneagram_8': 0.3, 'bias_emotional_suppress': 0.3},
        ),
        DecisionOption(
          text: '太衝動/冇耐性，成日轉軚',
          scores: {'enneagram_7': 0.5, 'enneagram_8': 0.5, 'P': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [2, 3, 4, 5, 6, 7, 8, 9, 1],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_2'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_2',
      phase: DecisionPhase.enneaDeep,
      scenario: '你細個嗰陣，成日俾人話你…',
      options: [
        DecisionOption(
          text: '太乖、太聽話、太在意人',
          scores: {'enneagram_2': 0.5, 'enneagram_9': 0.5, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '太怕死、太緊張、諗太多',
          scores: {'enneagram_6': 0.5, 'enneagram_5': 0.5, 'bias_catastrophizing': 0.2},
        ),
        DecisionOption(
          text: '太硬頸、太固執、唔聽人講',
          scores: {'enneagram_8': 0.5, 'enneagram_1': 0.5, 'enneagram_7': 0.3},
        ),
        DecisionOption(
          text: '太 hea、太是但、唔上心',
          scores: {'enneagram_9': 0.5, 'enneagram_7': 0.5, 'P': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [2, 9, 1, 6, 5, 8, 7],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_3'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_3',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得最難頂嘅係邊種人？',
      options: [
        DecisionOption(
          text: '自私、唔顧人感受嘅人',
          scores: {'enneagram_2': 0.5, 'enneagram_9': 0.5, 'enneagram_4': 0.3},
        ),
        DecisionOption(
          text: '冇腦、唔用邏輯、亂咁嚟嘅人',
          scores: {'enneagram_5': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.3},
        ),
        DecisionOption(
          text: '軟弱、冇立場、任人恰嘅人',
          scores: {'enneagram_8': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '虛偽、扮晒嘢、chur到盡嘅人',
          scores: {'enneagram_4': 0.5, 'enneagram_7': 0.3, 'enneagram_9': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [2, 9, 4, 5, 1, 6, 8, 3, 7],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_4'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_4',
      phase: DecisionPhase.enneaDeep,
      scenario: '你壓力爆煲嘅時候會…',
      options: [
        DecisionOption(
          text: '搵人傾訴，需要人陪',
          scores: {'enneagram_2': 0.5, 'enneagram_3': 0.5, 'enneagram_7': 0.3, 'E': 0.3},
        ),
        DecisionOption(
          text: '收埋自己，靜靜消化，唔想俾人知',
          scores: {'enneagram_5': 0.5, 'enneagram_4': 0.5, 'enneagram_9': 0.3, 'I': 0.3},
        ),
        DecisionOption(
          text: '發脾氣，要發洩出嚟先舒服',
          scores: {'enneagram_8': 0.5, 'enneagram_1': 0.5, 'enneagram_7': 0.3},
        ),
        DecisionOption(
          text: '乜都唔諗，攤屍放空，等佢自己過',
          scores: {'enneagram_9': 0.5, 'enneagram_7': 0.3, 'P': 0.3, 'health_positive': 0.05},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [2, 3, 7, 5, 4, 9, 8, 1],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_5'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_5',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得「成功」係…',
      options: [
        DecisionOption(
          text: '有好 close 嘅關係，俾人愛錫同需要',
          scores: {'enneagram_2': 0.5, 'enneagram_4': 0.5, 'enneagram_3': 0.3, 'F': 0.3},
        ),
        DecisionOption(
          text: '達到目標，俾人認同，有地位',
          scores: {'enneagram_3': 0.5, 'enneagram_8': 0.5, 'enneagram_1': 0.3, 'T': 0.3},
        ),
        DecisionOption(
          text: '有自由做自己鍾意嘅事，唔使俾人管',
          scores: {'enneagram_7': 0.5, 'enneagram_4': 0.5, 'enneagram_9': 0.3, 'P': 0.3},
        ),
        DecisionOption(
          text: '生活安穩，冇煩惱，平安是福',
          scores: {'enneagram_6': 0.5, 'enneagram_9': 0.5, 'enneagram_1': 0.3, 'J': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [2, 4, 3, 8, 1, 7, 9, 6],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_6'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_6',
      phase: DecisionPhase.enneaDeep,
      scenario: '你一日起碼會諗幾多次「人哋點睇我」？',
      options: [
        DecisionOption(
          text: '好多次，我成日在意人哋嘅反應同評價',
          scores: {'enneagram_3': 0.5, 'enneagram_2': 0.5, 'enneagram_4': 0.5, 'F': 0.3},
        ),
        DecisionOption(
          text: '間中會諗，但唔會影響我決定',
          scores: {'enneagram_6': 0.5, 'enneagram_5': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '好少，我做自己，人哋點諗關我咩事',
          scores: {'enneagram_8': 0.5, 'enneagram_7': 0.5, 'enneagram_5': 0.3, 'T': 0.3},
        ),
      ],
      discriminationPower: 0.7,
      targetEnneagramTypes: [3, 2, 4, 6, 5, 9, 8, 7],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_7'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_7',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得自己嘅精力多數用喺…',
      options: [
        DecisionOption(
          text: '照顧人、維持關係、幫人解決問題',
          scores: {'enneagram_2': 0.5, 'enneagram_9': 0.5, 'F': 0.3},
        ),
        DecisionOption(
          text: '追求目標、提升自己、做到最好',
          scores: {'enneagram_3': 0.5, 'enneagram_1': 0.5, 'enneagram_8': 0.3, 'T': 0.3},
        ),
        DecisionOption(
          text: '思考分析、研究學問、理解世界',
          scores: {'enneagram_5': 0.5, 'enneagram_6': 0.5, 'enneagram_4': 0.3},
        ),
        DecisionOption(
          text: '享受生活、搵新嘢玩、探索可能性',
          scores: {'enneagram_7': 0.5, 'enneagram_9': 0.3, 'P': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [2, 9, 3, 1, 8, 5, 6, 4, 7],
      phaseLabel: '九型深入分析…',
    );

    _questions['DQ_ENNEA_ALL_8'] = DecisionQuestion(
      id: 'DQ_ENNEA_ALL_8',
      phase: DecisionPhase.enneaDeep,
      scenario: '你覺得邊句最似你對金錢嘅態度？',
      options: [
        DecisionOption(
          text: '夠用就得，最緊要開心同人分享',
          scores: {'enneagram_2': 0.5, 'enneagram_7': 0.5, 'enneagram_9': 0.3},
        ),
        DecisionOption(
          text: '錢係安全感，要儲夠先安樂',
          scores: {'enneagram_6': 0.5, 'enneagram_1': 0.5, 'enneagram_5': 0.3},
        ),
        DecisionOption(
          text: '錢係工具，用嚟達成目標同買影響力',
          scores: {'enneagram_3': 0.5, 'enneagram_8': 0.5, 'enneagram_7': 0.3},
        ),
        DecisionOption(
          text: '夠我買到想要嘅嘢同體驗就得，唔使太多',
          scores: {'enneagram_4': 0.5, 'enneagram_7': 0.3, 'enneagram_9': 0.3},
        ),
      ],
      discriminationPower: 0.75,
      targetEnneagramTypes: [2, 7, 9, 6, 1, 5, 3, 8, 4],
      phaseLabel: '九型深入分析…',
    );

    // ═════════════════════════════════════════════════════════════════════
    // PHASE 3c: WING + HEALTH LEVEL QUESTIONS
    // ═════════════════════════════════════════════════════════════════════

    _questions['DQ_WING_5w4_5w6'] = DecisionQuestion(
      id: 'DQ_WING_5w4_5w6',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你研究緊一個topic，發現越睇越多嘢要學，你會…',
      options: [
        DecisionOption(
          text: '好興奮 — 呢個探索過程本身已經有意義，越深入越好',
          scores: {'enneagram_5': 0.5, 'enneagram_4': 0.5, 'health_good': 0.5, 'health_positive': 0.1},
        ),
        DecisionOption(
          text: '開始有啲焦慮 — 想整理晒所有資訊分類歸檔，怕miss咗嘢',
          scores: {'enneagram_5': 0.5, 'enneagram_6': 0.5, 'health_good': 0.2, 'health_negative': 0.3, 'bias_catastrophizing': 0.2},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [5, 4, 6],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_2w1_2w3'] = DecisionQuestion(
      id: 'DQ_WING_2w1_2w3',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你幫咗人但冇被多謝，你會…',
      options: [
        DecisionOption(
          text: '有啲委屈但覺得「做好事唔使回報」，下次都係會幫',
          scores: {'enneagram_2': 0.5, 'enneagram_1': 0.5, 'health_good': 0.5, 'health_positive': 0.1},
        ),
        DecisionOption(
          text: '下次唔會再咁幫佢，focus返自己先，唔可以蝕底',
          scores: {'enneagram_2': 0.5, 'enneagram_3': 0.5, 'health_good': 0.1, 'health_negative': 0.3},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [2, 1, 3],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_9w8_9w1'] = DecisionQuestion(
      id: 'DQ_WING_9w8_9w1',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '朋友不斷改變計劃，最後一刻先confirm，你會…',
      options: [
        DecisionOption(
          text: '心里有啲忟但費事出聲，跟佢啦，費事搞到唔開心',
          scores: {'enneagram_9': 0.5, 'enneagram_8': 0.3, 'health_good': 0.2, 'bias_emotional_suppress': 0.3},
        ),
        DecisionOption(
          text: '溫和咁同佢講「下次早啲話我知」，setting boundary',
          scores: {'enneagram_9': 0.5, 'enneagram_1': 0.5, 'health_good': 0.5, 'health_positive': 0.1},
        ),
      ],
      discriminationPower: 0.85,
      targetEnneagramTypes: [9, 8, 1],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_3w2_3w4'] = DecisionQuestion(
      id: 'DQ_WING_3w2_3w4',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你完成一個大project，你最開心係…',
      options: [
        DecisionOption(
          text: '得到人哋認同同讚賞，證明自己價值',
          scores: {'enneagram_3': 0.5, 'enneagram_2': 0.5, 'health_good': 0.3, 'enneagram_7': 0.2},
        ),
        DecisionOption(
          text: '自己知道自己做得好，內在滿足感，唔使其他人知',
          scores: {'enneagram_3': 0.5, 'enneagram_4': 0.5, 'health_good': 0.5, 'health_positive': 0.1},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [3, 2, 4],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_4w3_4w5'] = DecisionQuestion(
      id: 'DQ_WING_4w3_4w5',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你創作/寫咗啲嘢，你想俾人睇嗎？',
      options: [
        DecisionOption(
          text: '想！我想俾人睇到我嘅作品，希望有人欣賞',
          scores: {'enneagram_4': 0.5, 'enneagram_3': 0.5, 'health_good': 0.3},
        ),
        DecisionOption(
          text: '有啲想但又怕… 其實放喺度自己欣賞就算',
          scores: {'enneagram_4': 0.5, 'enneagram_5': 0.5, 'health_good': 0.5, 'bias_internal_attribution': 0.2},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [4, 3, 5],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_6w5_6w7'] = DecisionQuestion(
      id: 'DQ_WING_6w5_6w7',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你準備去一個未去過嘅地方，你會…',
      options: [
        DecisionOption(
          text: 'research到足，plan好晒路線同backup plan先安心',
          scores: {'enneagram_6': 0.5, 'enneagram_5': 0.5, 'J': 0.3, 'health_good': 0.3, 'bias_catastrophizing': 0.2},
        ),
        DecisionOption(
          text: '大概睇下就去，有咩事到時候再算，船到橋頭自然直',
          scores: {'enneagram_6': 0.5, 'enneagram_7': 0.5, 'P': 0.3, 'health_good': 0.5, 'health_positive': 0.1},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [6, 5, 7],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_7w6_7w8'] = DecisionQuestion(
      id: 'DQ_WING_7w6_7w8',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你plan緊一個trip，你會…',
      options: [
        DecisionOption(
          text: 'plan幾個option，留啲flexibility，但都想有啲計劃',
          scores: {'enneagram_7': 0.5, 'enneagram_6': 0.5, 'P': 0.3, 'health_good': 0.3},
        ),
        DecisionOption(
          text: '買機票就走，去到再算，最緊要係個experience',
          scores: {'enneagram_7': 0.5, 'enneagram_8': 0.5, 'P': 0.3, 'health_good': 0.5, 'health_positive': 0.1},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [7, 6, 8],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_8w7_8w9'] = DecisionQuestion(
      id: 'DQ_WING_8w7_8w9',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你見到有人俾人恰，你會…',
      options: [
        DecisionOption(
          text: '即刻企出嚟幫佢，我最唔中意見到不公平',
          scores: {'enneagram_8': 0.5, 'enneagram_7': 0.5, 'E': 0.3, 'health_good': 0.5, 'health_positive': 0.1},
        ),
        DecisionOption(
          text: '睇定啲先，如果唔关我事就唔出聲，費事惹麻煩',
          scores: {'enneagram_8': 0.5, 'enneagram_9': 0.5, 'health_good': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [8, 7, 9],
      phaseLabel: '翼型確認中…',
    );

    _questions['DQ_WING_1w9_1w2'] = DecisionQuestion(
      id: 'DQ_WING_1w9_1w2',
      phase: DecisionPhase.enneaWingHealth,
      scenario: '你見到有人做錯嘢，你會…',
      options: [
        DecisionOption(
          text: '會指出佢錯咩，但用溫和方式，唔想搞到衝突',
          scores: {'enneagram_1': 0.5, 'enneagram_9': 0.5, 'F': 0.3, 'health_good': 0.5, 'health_positive': 0.1},
        ),
        DecisionOption(
          text: '直接話佢知佢錯咩，教佢點先啱，幫佢改善',
          scores: {'enneagram_1': 0.5, 'enneagram_2': 0.5, 'T': 0.3, 'health_good': 0.3},
        ),
      ],
      discriminationPower: 0.8,
      targetEnneagramTypes: [1, 9, 2],
      phaseLabel: '翼型確認中…',
    );

    // ═════════════════════════════════════════════════════════════════════
    // EXTRA HK SITUATIONAL QUESTIONS (for variety)
    // ═════════════════════════════════════════════════════════════════════

    _questions['DQ_HK_EXTRA_1'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_1',
      phase: DecisionPhase.mbtiRouting,
      scenario: '搭lift得你同一個唔識嘅人，你會…',
      options: [
        DecisionOption(
          text: '望住手機扮忙，唔想有眼神接觸',
          scores: {'I': 1.0, 'enneagram_5': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '微笑點頭，possibly講句「今日好熱」',
          scores: {'E': 1.0, 'enneagram_2': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '冇所謂，正常咁等lift到',
          scores: {'P': 0.5, 'enneagram_9': 0.5},
        ),
      ],
      discriminationPower: 0.6,
      targetDimensions: ['EI'],
      targetEnneagramTypes: [5, 9, 2, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_2'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_2',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你電話冇電，但又未返到屋企，你會…',
      options: [
        DecisionOption(
          text: '好焦慮，覺得同世界斷線，好冇安全感',
          scores: {'J': 0.5, 'enneagram_6': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '幾好喺，難得冇人搵到我，享受寧靜',
          scores: {'I': 0.5, 'enneagram_5': 0.5, 'enneagram_9': 0.5, 'health_positive': 0.05},
        ),
        DecisionOption(
          text: '睇下有冇街邊舖頭可以借charge',
          scores: {'E': 0.5, 'P': 0.5, 'enneagram_7': 0.5, 'enneagram_8': 0.3},
        ),
      ],
      discriminationPower: 0.6,
      targetDimensions: ['EI', 'JP'],
      targetEnneagramTypes: [6, 3, 5, 9, 7, 8],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_3'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_3',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你見到一個activist喺街度派傳單，你會…',
      options: [
        DecisionOption(
          text: '會停低聽佢講，了解多啲',
          scores: {'N': 0.5, 'F': 0.5, 'enneagram_4': 0.5, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '禮貌揮手唔要，趕時間',
          scores: {'T': 0.5, 'J': 0.5, 'enneagram_1': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '會攞張傳單但唔會睇',
          scores: {'P': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '同佢傾幾句，問佢點解會參與',
          scores: {'E': 0.5, 'N': 0.5, 'enneagram_7': 0.5, 'enneagram_5': 0.5},
        ),
      ],
      discriminationPower: 0.65,
      targetDimensions: ['EI', 'TF', 'SN'],
      targetEnneagramTypes: [4, 2, 1, 3, 9, 7, 5],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_4'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_4',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你喺茶餐廳叫咗常餐，但嚟到嘅炒蛋變咗煎蛋，你會…',
      options: [
        DecisionOption(
          text: '叫阿姐換過，我落單係炒蛋就係炒蛋',
          scores: {'J': 0.5, 'T': 0.5, 'enneagram_1': 0.5, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '是但啦，差唔多，費事要人等',
          scores: {'P': 0.5, 'enneagram_9': 1.0, 'F': 0.3},
        ),
        DecisionOption(
          text: '影張相send俾friend笑吓，然後照食',
          scores: {'P': 0.5, 'enneagram_7': 0.5, 'E': 0.3},
        ),
      ],
      discriminationPower: 0.65,
      targetDimensions: ['JP', 'TF'],
      targetEnneagramTypes: [1, 8, 9, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_5'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_5',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你朋友send咗一條好長嘅voice message俾你，你會…',
      options: [
        DecisionOption(
          text: '聽晒佢，然後慢慢覆返',
          scores: {'F': 0.5, 'S': 0.5, 'enneagram_2': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '見到voice msg已經唔想聽，text pls',
          scores: {'T': 0.5, 'N': 0.5, 'enneagram_5': 0.5, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '加快速度聽，get到重點就算',
          scores: {'T': 0.5, 'P': 0.5, 'enneagram_3': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '轉文字睇，快靚正',
          scores: {'T': 0.5, 'enneagram_5': 0.5, 'enneagram_1': 0.5},
        ),
      ],
      discriminationPower: 0.6,
      targetDimensions: ['TF', 'SN'],
      targetEnneagramTypes: [2, 9, 5, 1, 3, 7],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_6'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_6',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你中咗六合彩細獎500蚊，你會…',
      options: [
        DecisionOption(
          text: '即刻諗點用/儲起，規劃一吓',
          scores: {'J': 0.5, 'S': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '請friend食飯/買嘢俾屋企人，開心share',
          scores: {'F': 0.5, 'enneagram_2': 0.5, 'enneagram_7': 0.5, 'E': 0.3},
        ),
        DecisionOption(
          text: '買自己想買好耐嘅嘢，獎勵自己',
          scores: {'P': 0.5, 'enneagram_7': 0.5, 'enneagram_4': 0.5},
        ),
      ],
      discriminationPower: 0.55,
      targetDimensions: ['JP', 'TF'],
      targetEnneagramTypes: [1, 6, 2, 7, 4],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_7'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_7',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你排隊等緊買限量波鞋/模型/化妝品，排咗一個鐘，前面仲有好多人，你會…',
      options: [
        DecisionOption(
          text: '照排，話晒排咗咁耐，唔可以放棄',
          scores: {'J': 0.5, 'S': 0.5, 'enneagram_1': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '算啦，下次再買，費事晒時間',
          scores: {'P': 0.5, 'enneagram_9': 0.5, 'enneagram_7': 0.5},
        ),
        DecisionOption(
          text: '一邊排一邊搵friend吹水/睇phone，時間好快過',
          scores: {'E': 0.5, 'enneagram_7': 0.5, 'enneagram_2': 0.3},
        ),
        DecisionOption(
          text: '評估吓前面有幾多人、每個人要幾耐、值唔值得等',
          scores: {'T': 0.5, 'enneagram_5': 0.5, 'enneagram_6': 0.5},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['JP', 'EI', 'TF'],
      targetEnneagramTypes: [1, 3, 9, 7, 5, 6, 2],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_8'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_8',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你係公司group入面，老細話「有冇人自願做presentation」，你會…',
      options: [
        DecisionOption(
          text: '主動舉手 — 貪有表現機會',
          scores: {'E': 1.0, 'enneagram_3': 0.5, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '扮睇唔到，唔好搵我',
          scores: {'I': 1.0, 'enneagram_5': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '等一陣，如果冇人举手我先上',
          scores: {'F': 0.5, 'enneagram_9': 0.5, 'enneagram_2': 0.5},
        ),
        DecisionOption(
          text: '即刻分析自己夠唔夠時間/prepare好唔好',
          scores: {'T': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
      ],
      discriminationPower: 0.75,
      targetDimensions: ['EI', 'TF'],
      targetEnneagramTypes: [3, 8, 5, 9, 2, 1, 6],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_9'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_9',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你執屋發現以前中學嘅紀念品/日記，你會…',
      options: [
        DecisionOption(
          text: '坐低落嚟慢慢睇，回味過去，好懷念',
          scores: {'S': 0.5, 'F': 0.5, 'enneagram_4': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '望兩眼就放返埋，過去就過去了',
          scores: {'T': 0.5, 'N': 0.5, 'enneagram_5': 0.5, 'enneagram_1': 0.5},
        ),
        DecisionOption(
          text: '影相send俾舊friend笑吓',
          scores: {'E': 0.5, 'enneagram_7': 0.5, 'enneagram_3': 0.3},
        ),
      ],
      discriminationPower: 0.6,
      targetDimensions: ['SN', 'TF'],
      targetEnneagramTypes: [4, 9, 5, 1, 7, 3],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_10'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_10',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你約咗friend 8點，但friend 8:15先話會遲半個鐘，你會…',
      options: [
        DecisionOption(
          text: '「下次約早啲啦，我聽日要返早」— 直接表達',
          scores: {'J': 0.5, 'T': 0.5, 'enneagram_1': 0.5, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '「唔緊要，我等你」— 好體諒',
          scores: {'F': 0.5, 'enneagram_2': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '自己去附近行吓，冇所謂',
          scores: {'P': 0.5, 'enneagram_7': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '心裡有啲唔開心但唔會講出口',
          scores: {'I': 0.5, 'enneagram_4': 0.5, 'enneagram_9': 0.5, 'bias_emotional_suppress': 0.2},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['JP', 'TF', 'EI'],
      targetEnneagramTypes: [1, 8, 2, 9, 7, 4],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_11'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_11',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你覺得以下邊個活動最似你嘅週末？',
      options: [
        DecisionOption(
          text: '約班friend行山/踩單車/聚會',
          scores: {'E': 0.5, 'S': 0.5, 'enneagram_7': 0.5, 'enneagram_3': 0.5},
        ),
        DecisionOption(
          text: '去咖啡店睇書/寫嘢/畫畫，一個人都好chill',
          scores: {'I': 0.5, 'N': 0.5, 'enneagram_4': 0.5, 'enneagram_5': 0.5},
        ),
        DecisionOption(
          text: '做家務/plan下星期/整理生活',
          scores: {'J': 0.5, 'S': 0.5, 'enneagram_1': 0.5, 'enneagram_6': 0.5},
        ),
        DecisionOption(
          text: '瞓到自然醒，睇吓有咩做先算',
          scores: {'P': 0.5, 'enneagram_9': 0.5, 'enneagram_7': 0.3},
        ),
      ],
      discriminationPower: 0.7,
      targetDimensions: ['EI', 'JP', 'SN'],
      targetEnneagramTypes: [7, 3, 4, 5, 1, 6, 9],
      phaseLabel: 'MBTI判定中…',
    );

    _questions['DQ_HK_EXTRA_12'] = DecisionQuestion(
      id: 'DQ_HK_EXTRA_12',
      phase: DecisionPhase.mbtiRouting,
      scenario: '你見到有人喺地鐵入面食嘢，你會…',
      options: [
        DecisionOption(
          text: '覺得冇乜嘢，我都試過趕時間',
          scores: {'P': 0.5, 'enneagram_7': 0.5, 'enneagram_9': 0.5},
        ),
        DecisionOption(
          text: '覺得佢冇公德心，應該要阻止',
          scores: {'J': 0.5, 'T': 0.5, 'enneagram_1': 1.0, 'enneagram_8': 0.5},
        ),
        DecisionOption(
          text: '望吓佢食咩，好唔好食',
          scores: {'S': 0.5, 'enneagram_7': 0.5, 'enneagram_3': 0.3},
        ),
        DecisionOption(
          text: '戴headphone當睇唔到，避免衝突',
          scores: {'F': 0.5, 'enneagram_9': 0.5, 'enneagram_5': 0.5, 'bias_emotional_suppress': 0.2},
        ),
      ],
      discriminationPower: 0.65,
      targetDimensions: ['JP', 'TF', 'SN'],
      targetEnneagramTypes: [7, 9, 1, 8, 3, 5],
      phaseLabel: 'MBTI判定中…',
    );
  }
}
