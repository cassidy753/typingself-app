/// Inferior Function data for all 16 MBTI types.
///
/// Each type has a known inferior (4th) cognitive function.
/// We provide:
/// - A short label (inferior function name)
/// - A daily HK-Cantonese practice task suggestion
/// - A description of what developing this function looks like
library;

class InferiorFunctionInfo {
  final String functionName; // e.g. "Ti (內傾思考)"
  final String dailyTask;    // HK Cantonese task for today
  final String description;  // What development looks like
  final String gripWarning;  // What happens under stress (inferior grip)

  const InferiorFunctionInfo({
    required this.functionName,
    required this.dailyTask,
    required this.description,
    required this.gripWarning,
  });
}

/// Look up InferiorFunctionInfo by MBTI type code.
InferiorFunctionInfo getInferiorFunctionInfo(String mbti) {
  return _inferiorMap[mbti.toUpperCase()] ?? _defaultInfo;
}

/// Get a random task variant for variety.
/// Pass a seed like today's date int to get a stable daily task.
String getDailyTask(String mbti, int daySeed) {
  final tasks = _dailyTasks[mbti.toUpperCase()] ?? _defaultTasks;
  return tasks[daySeed % tasks.length];
}

const _defaultInfo = InferiorFunctionInfo(
  functionName: '探索中',
  dailyTask: '今日用 5 分鐘留意自己嘅感受同諗法',
  description: '慢慢了解自己嘅盲點，每日做少少練習。',
  gripWarning: '留意壓力下嘅極端反應。',
);

// ──────────────── DATA ────────────────

const Map<String, InferiorFunctionInfo> _inferiorMap = {
  // ===== NF Idealists =====
  'ENFJ': InferiorFunctionInfo(
    functionName: 'Ti（內傾思考）',
    dailyTask: '今日揀一個你同意嘅觀點，寫低三點反駁佢',
    description: '發展邏輯 consistency，唔好因為人而信，要因為合理而信。',
    gripWarning: '壓力下會變得苛刻批判、鑽牛角尖、挑剔所有人嘅邏輯漏洞。',
  ),
  'INFJ': InferiorFunctionInfo(
    functionName: 'Se（外傾感覺）',
    dailyTask: '用 5 分鐘留意你手接觸到嘅每一樣嘢嘅質感',
    description: '練習留喺當下，感受身體訊號，唔好成日活喺未來。',
    gripWarning: '壓力下會對環境噪音/氣味極度敏感，甚至 sensory overload。',
  ),
  'ENFP': InferiorFunctionInfo(
    functionName: 'Si（內傾感覺）',
    dailyTask: '做一樣你尋日做過嘅事，留意今次有咩唔同',
    description: '學習沉澱經驗，重複做一件事都有新發現。',
    gripWarning: '壓力下會極度後悔過去，不斷 replay 錯誤，凌晨仲喺度諗「如果當年…」。',
  ),
  'INFP': InferiorFunctionInfo(
    functionName: 'Te（外傾思考）',
    dailyTask: '用一個 checklist 完成一個任務，每剔一項獎勵自己',
    description: '練習結構化執行，唔好等到完美先開始。',
    gripWarning: '壓力下會極度嚴格執行習慣，冇彈性，少咗一步就崩潰。',
  ),

  // ===== NT Rationals =====
  'ENTJ': InferiorFunctionInfo(
    functionName: 'Fi（內傾情感）',
    dailyTask: '問自己：我真心覺得咩係重要？（唔係「應該」重要）',
    description: '接觸自己內心嘅價值觀，唔好永遠用效率衡量一切。',
    gripWarning: '壓力下會衝動消費、放飛自我、突然 ignore 所有責任。',
  ),
  'INTJ': InferiorFunctionInfo(
    functionName: 'Se（外傾感覺）',
    dailyTask: '今日專心食一餐飯，唔睇電話，感受每一啖嘅味道',
    description: '練習感官覺察，活喺當下，唔好永遠 plan 緊未來。',
    gripWarning: '壓力下會瘋狂運動、暴食、沉迷感官刺激，做到受傷都繼續。',
  ),
  'ENTP': InferiorFunctionInfo(
    functionName: 'Si（內傾感覺）',
    dailyTask: '用 10 分鐘重睇你舊筆記/NOTES，搵一個你忽略咗嘅 insight',
    description: '學習從過去經驗提取價值，唔好永遠追新嘢。',
    gripWarning: '壓力下會變 control freak，強迫自己跟死 schedule，唔准改。',
  ),
  'INTP': InferiorFunctionInfo(
    functionName: 'Fe（外傾情感）',
    dailyTask: '今日同一個人講「我明白你感受」，唔好分析佢',
    description: '練習情感共鳴，唔好永遠用邏輯拆解人性。',
    gripWarning: '壓力下會對社交極度敏感，覺得所有人都唔鍾意自己。',
  ),

  // ===== SJ Guardians =====
  'ESTJ': InferiorFunctionInfo(
    functionName: 'Fi（內傾情感）',
    dailyTask: '今日做一個選擇，只係因為你想做，唔係因為「應該」做',
    description: '容許自己有 personal preference，唔好永遠用 duty 定義自己。',
    gripWarning: '壓力下會忽略所有責任，乜都話「唔關我事」，突然消失。',
  ),
  'ESFJ': InferiorFunctionInfo(
    functionName: 'Ti（內傾思考）',
    dailyTask: '今日為一個決定寫低三點「我嘅原因」，唔參考任何人嘅意見',
    description: '練習獨立思考，建立自己嘅邏輯框架。',
    gripWarning: '壓力下對細微 details 執著到瘋狂，為咗小事發脾氣。',
  ),
  'ISTJ': InferiorFunctionInfo(
    functionName: 'Ne（外傾直覺）',
    dailyTask: '今日對一個熟悉嘅事物問「如果…會點？」',
    description: '打開可能性，允許自己想像唔同嘅 outcome。',
    gripWarning: '壓力下極度悲觀想像未來，諗到最壞情況然後唔敢行動。',
  ),
  'ISFJ': InferiorFunctionInfo(
    functionName: 'Ne（外傾直覺）',
    dailyTask: '用 5 分鐘幻想你 5 年後嘅生活，唔好 judge 自己諗得唔合理',
    description: '練習抽象思維，容許自己天馬行空。',
    gripWarning: '壓力下覺得世界變得好混亂、冇意義，對 routine 以外嘅嘢極度抗拒。',
  ),

  // ===== SP Artisans =====
  'ESTP': InferiorFunctionInfo(
    functionName: 'Ni（內傾直覺）',
    dailyTask: '今日諗一個 3 年後想達到嘅目標，倒推返今日要做嘅第一步',
    description: '練習長期 vision，唔好永遠活在當下嘅刺激。',
    gripWarning: '壓力下突然對哲學/人生意義鑽牛角尖，凌晨同人 debate 存在主義。',
  ),
  'ESFP': InferiorFunctionInfo(
    functionName: 'Ni（內傾直覺）',
    dailyTask: '今日觀察一個朋友嘅行為 pattern，諗下背後可能嘅原因',
    description: '練習 pattern recognition，睇到表面之下嘅深層結構。',
    gripWarning: '壓力下焦慮未來會孤獨終老，睇未來 planning 睇到崩潰。',
  ),
  'ISTP': InferiorFunctionInfo(
    functionName: 'Fe（外傾情感）',
    dailyTask: '今日 send 一個簡單嘅 message 俾一個你 care 嘅人，唔需要理由',
    description: '練習情感表達，唔好永遠收埋自己。',
    gripWarning: '壓力下會突然情感爆發或者完全情感冷漠。',
  ),
  'ISFP': InferiorFunctionInfo(
    functionName: 'Te（外傾思考）',
    dailyTask: '今日為一件你成日 procrastinate 嘅事寫一個 3 步 action plan',
    description: '練習系統化思維，用結構幫自己行動。',
    gripWarning: '壓力下逼自己跟死一個系統，冇彈性，崩潰。',
  ),
};

// ────── Daily task variants for rotation ──────
const Map<String, List<String>> _dailyTasks = {
  'ENFJ': [
    '今日揀一個你同意嘅觀點，寫低三點反駁佢',
    '今日睇一篇文章，用邏輯拆解作者嘅論證有冇漏洞',
    '今日自己做一個決定，唔問任何人意見',
    '今日寫低三個「我覺得合理」嘅原則',
  ],
  'INFJ': [
    '用 5 分鐘留意你手接觸到嘅每一樣嘢嘅質感',
    '今日專心飲一杯水，感受溫度同口感',
    '做 5 分鐘伸展，留意邊個肌肉最緊',
    '今日行路嗰陣留意周圍 3 樣你平時唔會睇到嘅嘢',
  ],
  'ENFP': [
    '做一樣你尋日做過嘅事，留意今次有咩唔同',
    '今日重溫一個舊回憶，寫低一個你新發現嘅角度',
    '用 10 分鐘整理一個你成日去嘅 folder/notes',
    '今日重複做一個 routine，感受穩定嘅安全感',
  ],
  'INFP': [
    '用一個 checklist 完成一個任務，每剔一項獎勵自己',
    '今日為一個 project 設定具體 deadline',
    '用「優先級矩陣」分類你今日要做嘅嘢',
    '今日用 5 分鐘整理你嘅空間',
  ],
  'ENTJ': [
    '問自己：我真心覺得咩係重要？（唔係「應該」重要）',
    '今日做一件「冇生產力」但令你開心嘅事',
    '今日用一個鐘唔理效率，純粹享受過程',
    '寫低三件你感恩嘅人同事，唔係 achievement',
  ],
  'INTJ': [
    '今日專心食一餐飯，唔睇電話，感受每一啖嘅味道',
    '做 5 分鐘 body scan，由頭 scan 到落腳趾',
    '今日行路唔諗嘢，純粹感受周圍嘅環境',
    '摸一摸你附近嘅嘢嘅 texture，形容佢出嚟',
  ],
  'ENTP': [
    '用 10 分鐘重睇你舊筆記，搵一個你忽略咗嘅 insight',
    '今日做一個你上個月做過嘅 task，睇下有咩進步',
    '整理一個你成日開嘅 project 嘅檔案結構',
    '今日用一個舊方法解決一個新問題',
  ],
  'INTP': [
    '今日同一個人講「我明白你感受」，唔好分析佢',
    '今日 send 一個「掛住你」嘅 message 俾朋友',
    '同人傾計嗰陣淨係聽，唔好俾建議',
    '今日留意一個陌生人嘅情緒',
  ],
  'ESTJ': [
    '今日做一個選擇，只係因為你想做，唔係因為「應該」做',
    '今日俾自己 30 分鐘冇 schedule 嘅自由時間',
    '寫低三件你 personal 鍾意嘅嘢（唔係责任）',
    '今日容許自己話「我唔想」',
  ],
  'ESFJ': [
    '今日為一個決定寫低三點「我嘅原因」，唔參考任何人',
    '今日做一個 Logic puzzle 或者數獨',
    '寫低一個你嘅 opinion，唔需要 justify 俾人聽',
    '今日自己一個人食飯，唔搵人傾偈',
  ],
  'ISTJ': [
    '今日對一個熟悉嘅事物問「如果…會點？」',
    '今日試一條新路線返屋企/去某個地方',
    '用 5 分鐘 brainstorming 一個問題嘅 5 個解決方案',
    '今日試一個你未試過嘅食物/飲品',
  ],
  'ISFJ': [
    '用 5 分鐘幻想你 5 年後嘅生活，唔好 judge 自己',
    '今日睇一個你想去嘅地方嘅介紹',
    '問自己「如果冇任何限制，我會想做咩？」',
    '用 mind map 整理一個你嘅興趣',
  ],
  'ESTP': [
    '今日諗一個 3 年後嘅目標，倒推出今日第一步',
    '今日用 5 分鐘寫低你嘅「長期 vision」',
    '諗一個 pattern：你身邊嘅人成日做嘅同一件事',
    '今日為一個決定諗長期後果',
  ],
  'ESFP': [
    '今日觀察一個朋友嘅 behavior pattern',
    '今日睇一個分析/評論嘅文章，試下理解作者嘅框架',
    '用 5 分鐘諗一個你最近嘅經驗有咩 deeper meaning',
    '今日試下用「因為…所以…」解釋一個現象',
  ],
  'ISTP': [
    '今日 send 一個簡單嘅 message 俾一個你 care 嘅人',
    '今日同一個人講「我好開心識到你」',
    '留意今日邊一刻你 feel 到 connected to someone',
    '今日同一個 friend 約食飯，唔係為咗做啲咩',
  ],
  'ISFP': [
    '今日為一件成日 procrastinate 嘅事寫一個 3 步 plan',
    '今日用番茄鐘專注做一件事 25 分鐘',
    '為你嘅一個興趣設定一個小目標',
    '今日用 spreadsheet/app 追蹤一件事',
  ],
};

const List<String> _defaultTasks = [
  '今日用 5 分鐘留意自己嘅感受同諗法',
  '今日寫低一件你感恩嘅小事',
  '今日做一個深呼吸，淨係 focus 喺呼吸',
];
