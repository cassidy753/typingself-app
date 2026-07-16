// ═══════════════════════════════════════════════════════════════════════
// ShadowReportEngine — Stage 2 Shadow Report data model + engine
// Integrates NamingEngine (289 entries) for personality name lookup
// Covers all 144 MBTI × Enneagram combinations
// Daebi palette · HK Cantonese tone
// ═══════════════════════════════════════════════════════════════════════

import '../personality_naming/naming_engine.dart';

// ─── Health Level ───
enum HealthLevel { healthy, average, unhealthy }

// ─── Data Models ───

class ShadowPersona {
  final String name;
  final String description;
  final List<String> traits;
  final String maskPhrase;

  const ShadowPersona({
    required this.name,
    required this.description,
    required this.traits,
    required this.maskPhrase,
  });
}

class ShadowPattern {
  final String name;
  final String description;
  final List<String> triggerSituations;
  final String growthHint;

  const ShadowPattern({
    required this.name,
    required this.description,
    required this.triggerSituations,
    required this.growthHint,
  });
}

class DefenseMechanism {
  final String name;
  final String description;
  final String example;
  final String alternative;

  const DefenseMechanism({
    required this.name,
    required this.description,
    required this.example,
    required this.alternative,
  });
}

class RepressedFunction {
  final String functionName;
  final String description;
  final List<String> symptoms;
  final List<String> exercises;

  const RepressedFunction({
    required this.functionName,
    required this.description,
    required this.symptoms,
    required this.exercises,
  });
}

class ShadowReport {
  final String mbtiType;
  final String enneagramType;
  final HealthLevel health;
  final ShadowPersona persona;
  final ShadowPattern shadowPattern;
  final List<DefenseMechanism> defenses;
  final List<RepressedFunction> repressedFunctions;

  /// Convenience: get the NamingEngine personality name for this combo
  PersonalityName? get personalityName =>
      NamingEngine.getName(mbtiType, enneagramType);

  const ShadowReport({
    required this.mbtiType,
    required this.enneagramType,
    required this.health,
    required this.persona,
    required this.shadowPattern,
    required this.defenses,
    required this.repressedFunctions,
  });
}

// ─── Engine ───

class ShadowReportEngine {
  // ─── Temperament group lookup ───

  static String _temperamentGroup(String mbti) {
    if (const {'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'}.contains(mbti)) return 'SJ';
    if (const {'ISTP', 'ISFP', 'ESTP', 'ESFP'}.contains(mbti)) return 'SP';
    if (const {'INFJ', 'INFP', 'ENFJ', 'ENFP'}.contains(mbti)) return 'NF';
    return 'NT'; // INTJ, INTP, ENTJ, ENTP
  }

  static int _enneaBase(String ennea) =>
      int.tryParse(ennea.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;

  // ─── MBTI function stack ───

  static const Map<String, List<String>> _functionStack = {
    'INTJ': ['Ni', 'Te', 'Fi', 'Se', 'Ne', 'Ti', 'Fe', 'Si'],
    'INTP': ['Ti', 'Ne', 'Si', 'Fe', 'Te', 'Ni', 'Se', 'Fi'],
    'ENTJ': ['Te', 'Ni', 'Se', 'Fi', 'Ti', 'Ne', 'Si', 'Fe'],
    'ENTP': ['Ne', 'Ti', 'Fe', 'Si', 'Ni', 'Te', 'Fi', 'Se'],
    'INFJ': ['Ni', 'Fe', 'Ti', 'Se', 'Ne', 'Fi', 'Te', 'Si'],
    'INFP': ['Fi', 'Ne', 'Si', 'Te', 'Fe', 'Ni', 'Se', 'Ti'],
    'ENFJ': ['Fe', 'Ni', 'Se', 'Ti', 'Fi', 'Ne', 'Si', 'Te'],
    'ENFP': ['Ne', 'Fi', 'Te', 'Si', 'Ni', 'Fe', 'Ti', 'Se'],
    'ISTJ': ['Si', 'Te', 'Fi', 'Ne', 'Se', 'Ti', 'Fe', 'Ni'],
    'ISFJ': ['Si', 'Fe', 'Ti', 'Ne', 'Se', 'Fi', 'Te', 'Ni'],
    'ESTJ': ['Te', 'Si', 'Ne', 'Fi', 'Ti', 'Se', 'Ni', 'Fe'],
    'ESFJ': ['Fe', 'Si', 'Ne', 'Ti', 'Fi', 'Se', 'Ni', 'Te'],
    'ISTP': ['Ti', 'Se', 'Ni', 'Fe', 'Te', 'Si', 'Ne', 'Fi'],
    'ISFP': ['Fi', 'Se', 'Ni', 'Te', 'Fe', 'Si', 'Ne', 'Ti'],
    'ESTP': ['Se', 'Ti', 'Fe', 'Ni', 'Si', 'Te', 'Fi', 'Ne'],
    'ESFP': ['Se', 'Fi', 'Te', 'Ni', 'Si', 'Fe', 'Ti', 'Ne'],
  };

  static String _inferiorFunction(String mbti) => _functionStack[mbti]?[3] ?? '?';

  // ─── Enneagram core data ───

  static const Map<int, String> _enneaCoreFear = {
    1: '自己係壞、錯、唔完美',
    2: '唔被需要、冇人愛',
    3: '冇價值、失敗',
    4: '冇身份、平庸',
    5: '冇能力、被吞噬',
    6: '冇安全、被背叛',
    7: '被困、痛苦',
    8: '被控制、受傷',
    9: '分裂、失去連繫',
  };

  static const Map<int, String> _enneaPrimaryDefense = {
    1: 'Reaction Formation（反向形成）',
    2: 'Repression（壓抑）',
    3: 'Identification（認同）',
    4: 'Introjection（內射）',
    5: 'Isolation（隔離）',
    6: 'Projection（投射）',
    7: 'Rationalization（合理化）',
    8: 'Denial（否認）',
    9: 'Narcotization（麻醉）',
  };

  static const Map<int, String> _enneaSecondaryDefense = {
    1: 'Undoing（抵消）',
    2: 'Self-Deception（自欺）',
    3: 'Narcissistic Defenses（自戀防禦）',
    4: 'Idealization（理想化）',
    5: 'Intellectualization（理智化）',
    6: 'Displacement（轉移）',
    7: 'Sublimation（昇華）',
    8: 'Acting Out（行動化）',
    9: 'Somatization（軀體化）',
  };

  // ─── Persona Names Map (144 combos × temperament + ennea group) ───

  static const Map<String, Map<int, String>> _personaMap = {
    'SJ': {
      1: '規矩守門人', 2: '可靠幫手', 3: '專業執行者', 4: '沉默典範',
      5: '系統管理員', 6: '忠誠執行者', 7: '穩定中堅', 8: '鐵腕管家', 9: '和諧調解者',
    },
    'SP': {
      1: '精緻工匠', 2: '實用幫手', 3: '低調高手', 4: '與別不同嘅創作者',
      5: '沉默專家', 6: '謹慎實作者', 7: '即興玩家', 8: '硬朗實戰者', 9: '隨和實用者',
    },
    'NF': {
      1: '使命引導者', 2: '靈魂治癒者', 3: '高段位影響者', 4: '深度獨特者',
      5: '深邃觀察者', 6: '洞悉危機者', 7: '靈感夢想家', 8: '強勢引導者', 9: '平和夢想家',
    },
    'NT': {
      1: '系統完美主義者', 2: '策略性幫手', 3: '高階戰略家', 4: '與眾不同嘅策劃者',
      5: '深度系統建構者', 6: '策略性風險管理者', 7: '創新戰略家', 8: '權威戰略家', 9: '低調規劃者',
    },
  };

  // ─── Shadow Names Map (144 combos) ───

  static const Map<String, Map<int, String>> _shadowMap = {
    'SJ': {
      1: '道德警察', 2: '犧牲式控制者', 3: '工作狂Judge', 4: '隱形受害者',
      5: '資訊囤積者', 6: '疑心檢查者', 7: '偷偷放縱者', 8: '暴政控制者', 9: '被動抵抗者',
    },
    'SP': {
      1: '挑剔隱士', 2: '工具人', 3: '隱形冠軍', 4: '被誤解嘅天才',
      5: '知識獨佔者', 6: '偏執準備者', 7: '衝動逃避者', 8: '獨狼破壞者', 9: '懶惰天才',
    },
    'NF': {
      1: '完美主義先知', 2: '拯救者burnout', 3: '虛偽導師', 4: '悲劇先知',
      5: '情感隔離者', 6: '偏執預言者', 7: '逃避現實者', 8: '操控型先知', 9: '解離型夢想家',
    },
    'NT': {
      1: '獨裁改革者', 2: '冷漠規劃者', 3: '傲慢執行者', 4: '孤獨天才',
      5: '抽離嘅觀察者', 6: '偏執規劃者', 7: '不切實際嘅遠見者', 8: '操控型策劃者', 9: '消失嘅策略家',
    },
  };

  // ─── Inferior function descriptions ───

  static const Map<String, _InfData> _infData = {
    'Se': _InfData(
      description: '當下、感官體驗、身體感受、物質世界',
      symptoms: ['成日唔記得食飯', '唔注意身體信號', '對環境唔敏感'],
      exercises: ['每日做一件「純感官」嘅事（唔用手機沖涼、專心食一餐飯）'],
    ),
    'Si': _InfData(
      description: '傳統、習慣、個人歷史、身體記憶、穩定routine',
      symptoms: ['唔記得食藥', '成日遲到', '重複犯同一錯誤'],
      exercises: ['建立一個小routine', '記錄學習日記'],
    ),
    'Ni': _InfData(
      description: '長期規劃、象徵意義、深度反思、未來藍圖',
      symptoms: ['冇long-term plan', '成日last minute', '唔鍾意思考人生意義'],
      exercises: ['每個月一次「人生方向check-in」', '寫低未來3個月目標'],
    ),
    'Ne': _InfData(
      description: '可能性、即興、抽象聯想、新經驗',
      symptoms: ['抗拒改變', '對新事物持懷疑態度', 'plan得太死'],
      exercises: ['每月嘗試一件「新」嘅事', '練習「如果…會點？」思考'],
    ),
    'Fe': _InfData(
      description: '社交和諧、群體情感、他人感受、表達情感',
      symptoms: ['社交場合覺得煩', '唔知點安慰人', '忽略群體氣氛'],
      exercises: ['每日一個小社交gesture（讚人一句、問人有冇需要幫手）'],
    ),
    'Te': _InfData(
      description: '效率、組織、客觀標準、外部執行',
      symptoms: ['拖延', '唔擅長計劃', '被deadline追住'],
      exercises: ['用todo list', '每日完成3件細嘢'],
    ),
    'Fi': _InfData(
      description: '個人價值、情感真實性、內在道德感、自我關懷',
      symptoms: ['忽略自己感受', '唔知自己真正想要咩', 'burnout都繼續做'],
      exercises: ['每日寫低一個「我覺得…」嘅句子', '練習辨識情緒'],
    ),
    'Ti': _InfData(
      description: '邏輯一致性、客觀分析、個人界線、內在邏輯',
      symptoms: ['太過遷就人', '失去自我立場', '難以做理性決定'],
      exercises: ['每日一個「我嘅意見係…因為…」練習'],
    ),
  };

  // ─── Description templates per temperament ───

  static String _personaDesc(String mbti, String ennea) {
    final group = _temperamentGroup(mbti);
    final base = _enneaBase(ennea);
    final name = _personaMap[group]?[base] ?? '探索者';

    switch (group) {
      case 'SJ':
        return '你俾人見到嘅係一個可靠、盡責、守規矩嘅$name。你覺得自己應該成熟、穩定、俾到人安全感。無論係工作定生活，你都有自己嘅一套規則，而且你覺得呢啲規則係「正常」嘅。';
      case 'SP':
        return '你俾人見到嘅係一個靈活、隨心、鍾意新鮮感嘅$name。你覺得人生最緊要開心，唔好太認真。你擅長即興應變，係大家眼中嘅「chill人」。';
      case 'NF':
        return '你俾人見到嘅係一個有深度、有同理心嘅$name。你希望每個人都睇到你嘅善良同智慧。你擅長讀取情緒，總係第一時間伸出援手。';
      case 'NT':
        return '你俾人見到嘅係一個理性、聰明、有遠見嘅$name。你覺得情感係低效嘅，理性先係解決問題嘅方法。你擅長分析同策略規劃。';
      default:
        return '你俾人見到嘅係一個不斷了解緊自己嘅探索者。';
    }
  }

  static String _shadowDesc(String mbti, String ennea) {
    final group = _temperamentGroup(mbti);
    final base = _enneaBase(ennea);
    final name = _shadowMap[group]?[base] ?? '未知嘅陰影';
    final fear = _enneaCoreFear[base] ?? '未知';
    final infFunc = _inferiorFunction(mbti);

    return '當你嘅核心恐懼——「$fear」——被觸發時，你會跌入$infFunc主導嘅陰影模式：你變成「$name」。呢個時候，你嘅行為會同平時好唔同，甚至你自己都唔認得自己。';
  }

  static List<String> _triggers(String mbti, String ennea) {
    final group = _temperamentGroup(mbti);
    switch (group) {
      case 'SJ':
        return ['計劃被打亂', '被人質疑你嘅做法', '身邊人唔守規矩', '失控嘅情境'];
      case 'SP':
        return ['感到被困或被限制', '重複沉悶嘅routine', '被人要求commitment', '失去自由選擇'];
      case 'NF':
        return ['你嘅付出冇被珍惜', '你嘅深度冇被理解', '人際衝突', '感到孤獨'];
      case 'NT':
        return ['你嘅理性系統失效', '被人挑戰你嘅能力', '情感局面控制唔到', '感到脆弱'];
      default:
        return ['壓力大嘅時候'];
    }
  }

  static String _growthHint(String mbti, String ennea, HealthLevel h) {
    final group = _temperamentGroup(mbti);

    if (h == HealthLevel.unhealthy) return '如果你發現以上描述同你好似，建議你搵專業人士傾吓。Shadow唔係你嘅全部，佢只係你未認識嘅自己。';

    switch (group) {
      case 'SJ':
        return '練習放低控制：每星期一次，容許自己「唔知點」、「冇計劃」、「求其」。你嘅價值唔係嚟自你做到幾多，而係你本身就足夠。';
      case 'SP':
        return '練習停低：每日5分鐘，冇電話、冇音樂、冇刺激，純粹同自己相處。你嘅逃避喺保護你，但你都值得面對真實。';
      case 'NF':
        return '練習直接表達需要：唔係一定要等人明你，你可以直接講「我今日好攰，我需要被照顧」。你嘅脆弱唔係弱點，係人性。';
      case 'NT':
        return '練習感受先行：每日一個「我覺得…」嘅句子。你嘅理性係工具，唔係身份。最聰明嘅面具，往往保護緊最受傷嘅心。';
      default:
        return 'Shadow係你未認識嘅自己，唔係你嘅敵人。';
    }
  }

  /// Primary defense description with MBTI flavor
  static DefenseMechanism _primaryDefense(String mbti, String ennea) {
    final base = _enneaBase(ennea);
    final name = _enneaPrimaryDefense[base] ?? '未知';

    final descMap = <int, String>{
      1: '你將內心嘅「壞」衝動反轉成「好」行為——內心嬲人，反而對人更加好。呢個防禦令你睇唔到自己真實嘅情緒。',
      2: '你將自己嘅需要壓落到潛意識，focus晒喺人哋身上。你唔係冇需要，你係唔敢承認自己有需要。',
      3: '你認同成功嘅形象多過真實嘅自己。你唔係唔知自己想要咩，你係驚停低咗之後發現自己乜都冇。',
      4: '你將失落嘅對象「內化」成自己嘅一部分——你唔係懷念過去，你係唔敢面對現在。',
      5: '你將情感同思想隔離，用「客觀分析」去迴避感受。你分析緊你嘅感受，並唔等於你感受緊。',
      6: '你將內心嘅唔安全投射出去，覺得「全世界都靠唔住」。其實係你自己唔信自己。',
      7: '你為所有衝動行為搵「合理」理由——「我買呢樣嘢係因為…」「我咁做係因為…」。其實你只係唔想面對空虛。',
      8: '你否認脆弱——「我冇事」、「我唔需要人幫」。否認唔等於消失，只係令啲嘢喺暗处长更大。',
      9: '你用「冇所謂」去麻醉自己嘅存在——你唔係冇意見，你係驚有意見之後會失去和諧。',
    };

    final exampleMap = <int, String>{
      1: 'OT到凌晨三點仲檢查緊個email有冇typo，因為內心覺得「如果出錯就代表我唔夠好」',
      2: 'friend問你「你要唔要幫手？」你話「唔使啦我自己搞得掂」，但其實你已經攰到想喊',
      3: '被讚「好叻」嘅時候你覺得「仲未夠」，因為你內心有個聲音話「你值得被愛係因為你做到嘢」',
      4: '見到人哋post幸福生活，你會覺得「點解佢有我冇？」，其實你忽略咗自己擁有嘅嘢',
      5: '朋友喊，你唔係攬住佢，而係分析「你喊係因為你嘅童年創傷…」',
      6: '伴侶遲覆message，你已經諗好晒佢出軌嘅一百種可能',
      7: '覺得空虛 -> 即刻book機票去旅行，因為「我需要充電」',
      8: '明明好攰，朋友問你「你冇嘢啊嘛？」你大聲話「好到唔能再好啊」',
      9: '伴侶問你想食咩，你話「是但啦」，其實你內心有 preference，但你覺得講出嚟好麻煩',
    };

    final altMap = <int, String>{
      1: '容許自己「唔完美」——練習講「咁樣都夠好啦」',
      2: '練習直接講需要——「我需要幫忙」、「我需要休息」',
      3: '練習唔做嘢嘅價值——你值得被愛唔係因為你做到幾多',
      4: '練習感恩——每日寫低3件「已經有」嘅嘢',
      5: '練習感受——「我分析緊我嘅感受」≠「我感受緊」',
      6: '練習信任——先信自己可以handle任何結果',
      7: '練習停低——空虛嘅反面唔係刺激，而係連結',
      8: '練習脆弱——「我都會驚㗎」呢五個字可以解放你',
      9: '練習有立場——「我想要A，因為…」三句就夠',
    };

    return DefenseMechanism(
      name: name,
      description: descMap[base] ?? '你有一套自動化嘅心理防禦機制去保護你。',
      example: exampleMap[base] ?? '當你感到壓力時，你會不自覺用呢個防禦機制。',
      alternative: altMap[base] ?? '練習覺察：停一停，問自己「我而家用緊咩防禦？」',
    );
  }

  static DefenseMechanism _secondaryDefense(String mbti, String ennea) {
    final base = _enneaBase(ennea);
    final name = _enneaSecondaryDefense[base] ?? '未知';

    final descMap = <int, String>{
      1: '你用新行動去「抵消」舊嘅過錯——糾結一個 mistake，然後做十件完美嘅事去 cover。',
      2: '你呃自己「我咁做係為咗佢好」，其實你係想被需要。',
      3: '你需要不斷被確認「你係特別嘅、成功嘅」，否則你會 feel worthless。',
      4: '你將人、關係、自己放到一個無法達到嘅標準——「如果佢係真命天子，佢應該自動明我」。',
      5: '你用理論同知識去隔離情感——「我唔係喊，我係喺度觀察自己嘅情緒反應」。',
      6: '你將對自己嘅唔信任轉移去 authority figure——「啲政府/公司/父母信唔過」。',
      7: '你將痛苦能量轉化為創造力——畫畫、寫作、創業，但唔俾自己處理傷口。',
      8: '你用行動代替感受——嬲就郁手、唔開心就嗌交、唔安就控制。',
      9: '你嘅心理壓力會化成身體症狀——頭痛、胃痛、皮膚敏感，全部都係你未講出口嘅嘢。',
    };

    return DefenseMechanism(
      name: name,
      description: descMap[base] ?? '次要防禦機制，喺主要機制唔夠用嘅時候出場。',
      example: _secondaryExample(base),
      alternative: '留意呢個模式，試下喺佢出現之前停一停。',
    );
  }

  static String _secondaryExample(int base) {
    const examples = {
      1: '同同事吵完交，覺得自己講錯嘢，第二日買咖啡俾全team',
      2: '幫人幫到 burnout，但同自己講「我鍾意幫人㗎」',
      3: 'interview完覺得自己表現唔好，即刻報名再進修',
      4: '拍拖初期覺得對方完美，後來發現對方「原來都係普通人」就失望',
      5: '失戀之後寫一篇心理學分析文〈親密關係終結嘅五大原因〉',
      6: '覺得公司政策有問題，就認定management想逼走人',
      7: '心情差嘅時候寫咗首歌/畫咗幅畫，但唔敢面對自己點解唔開心',
      8: '覺得 partner 有嘢瞞住自己，直接 check 佢電話',
      9: '每次見父母前都會頭痛/肚痛，其實係唔想面對佢哋嘅期望',
    };
    return examples[base] ?? '你喺壓力下會自動啟用呢個模式。';
  }

  // ─── Repressed Functions generation ───

  static RepressedFunction _inferiorFunctionData(String mbti, HealthLevel h) {
    final inf = _inferiorFunction(mbti);
    final data = _infData[inf] ?? _InfData(
      description: '壓抑咗嘅認知功能',
      symptoms: ['需要更了解自己嘅呢個部分'],
      exercises: ['慢慢探索'],
    );

    return RepressedFunction(
      functionName: '$inf（Inferior Function）',
      description: '你壓抑咗嘅係「${data.description}」。健康時你可以有意識地使用佢；壓力大時佢會以「grip」形式失控爆發。',
      symptoms: h == HealthLevel.unhealthy
          ? [...data.symptoms, '身體健康明顯受影響', '失眠/食慾失調']
          : data.symptoms,
      exercises: data.exercises,
    );
  }

  static RepressedFunction _shadowFunctionData(String mbti) {
    final stack = _functionStack[mbti] ?? [];
    final shadow = stack.length > 4 ? stack[4] : '?';
    final opposing = stack.length > 5 ? stack[5] : '?';

    return RepressedFunction(
      functionName: '$shadow / $opposing（Shadow Functions）',
      description: '呢啲係你嘅「Shadow Functions」——你覺得「我唔係咁嘅」或者會用嚟 judge 人。第5功能（$shadow）你主動拒絕使用；第6功能（$opposing）你會用嚟批評人。',
      symptoms: [
        '會 judge 人用呢個功能嘅方式',
        '覺得「正常人唔會咁做」',
        '壓力下會突然用呢個功能但用得好差',
      ],
      exercises: [
        '試下用開放態度觀察人哋點用呢個功能',
        '練習「人哋咁做都有佢嘅理由」',
      ],
    );
  }

  // ─── Main generate method ───

  ShadowReport generate(String mbti, String ennea, [HealthLevel health = HealthLevel.average]) {
    final group = _temperamentGroup(mbti);
    final base = _enneaBase(ennea);
    final personaName = _personaMap[group]?[base] ?? '探索者';
    final shadowName = _shadowMap[group]?[base] ?? '未知嘅陰影';

    return ShadowReport(
      mbtiType: mbti,
      enneagramType: ennea,
      health: health,
      persona: ShadowPersona(
        name: personaName,
        description: _personaDesc(mbti, ennea),
        traits: _personaTraits(mbti, ennea),
        maskPhrase: _maskPhrase(mbti, ennea),
      ),
      shadowPattern: ShadowPattern(
        name: shadowName,
        description: _shadowDesc(mbti, ennea),
        triggerSituations: _triggers(mbti, ennea),
        growthHint: _growthHint(mbti, ennea, health),
      ),
      defenses: [
        _primaryDefense(mbti, ennea),
        _secondaryDefense(mbti, ennea),
      ],
      repressedFunctions: [
        _inferiorFunctionData(mbti, health),
        _shadowFunctionData(mbti),
      ],
    );
  }

  List<String> _personaTraits(String mbti, String ennea) {
    final group = _temperamentGroup(mbti);
    switch (group) {
      case 'SJ':
        return ['可靠、盡責', '守規矩、有原則', '照顧身邊人', '擅長執行同管理'];
      case 'SP':
        return ['靈活、即興', '感官敏銳', '享受當下', '擅長應變'];
      case 'NF':
        return ['有同理心、深度', '理想主義', '擅長理解人', '有創造力'];
      case 'NT':
        return ['理性、分析力強', '有遠見', '擅長策略', '追求能力同知識'];
      default:
        return ['探索中'];
    }
  }

  String _maskPhrase(String mbti, String ennea) {
    final group = _temperamentGroup(mbti);
    switch (group) {
      case 'SJ':
        return '「我搞得掂所有嘢，唔使擔心我」';
      case 'SP':
        return '「我冇所謂㗎，是但啦」';
      case 'NF':
        return '「我理解你，但你有冇理解我？」';
      case 'NT':
        return '「我冇問題，呢件事好合理」';
      default:
        return '「了解自己，贏返自己」';
    }
  }
}

// ─── Internal helper ───

class _InfData {
  final String description;
  final List<String> symptoms;
  final List<String> exercises;

  const _InfData({
    required this.description,
    required this.symptoms,
    required this.exercises,
  });
}
