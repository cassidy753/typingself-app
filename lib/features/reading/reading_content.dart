// ═══════════════════════════════════════════════════════════════════════
// Reading content model — 書本內容模型
// Each "Book" = one MBTI/Enneagram type's reading content
// Content stored as structured data with emoji formatting
// ═══════════════════════════════════════════════════════════════════════

// ─── BOOK MODEL ───
class ReadingBook {
  final String id;           // e.g. "enfj", "enneagram_1"
  final String title;        // 書名
  final String subtitle;     // 副標題
  final String emoji;        // Cover emoji
  final String category;     // "MBTI" / "Enneagram" / "Growth" / "Shadow"
  final String mbtiType;     // e.g. "ENFJ" or ""
  final String enneaType;    // e.g. "1" or ""
  final List<ReadingChapter> chapters;
  final String coverColor;   // Hex color string

  const ReadingBook({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.category,
    this.mbtiType = '',
    this.enneaType = '',
    required this.chapters,
    this.coverColor = '0xFF9B72AA',
  });

  int get totalChapters => chapters.length;
  int get totalSections {
    int count = 0;
    for (final ch in chapters) count += ch.sections.length;
    return count;
  }
}

// ─── CHAPTER MODEL ───
class ReadingChapter {
  final String id;
  final String title;
  final String emoji;
  final List<ReadingSection> sections;

  const ReadingChapter({
    required this.id,
    required this.title,
    required this.emoji,
    required this.sections,
  });

  int get totalSections => sections.length;
}

// ─── SECTION MODEL ───
class ReadingSection {
  final String id;
  final String title;
  final String content; // Markdown-like with emojis

  const ReadingSection({
    required this.id,
    required this.title,
    required this.content,
  });
}

// ─── READING PROGRESS ───
class ReadingProgress {
  final String bookId;
  final int chapterIndex;
  final int sectionIndex;
  final double scrollPosition;
  final DateTime? lastReadAt;
  final bool completed;

  const ReadingProgress({
    required this.bookId,
    this.chapterIndex = 0,
    this.sectionIndex = 0,
    this.scrollPosition = 0,
    this.lastReadAt,
    this.completed = false,
  });

  ReadingProgress copyWith({
    int? chapterIndex,
    int? sectionIndex,
    double? scrollPosition,
    DateTime? lastReadAt,
    bool? completed,
  }) {
    return ReadingProgress(
      bookId: bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      sectionIndex: sectionIndex ?? this.sectionIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'chapterIndex': chapterIndex,
    'sectionIndex': sectionIndex,
    'scrollPosition': scrollPosition,
    'lastReadAt': lastReadAt?.toIso8601String() ?? '',
    'completed': completed,
  };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
    bookId: json['bookId'] as String,
    chapterIndex: json['chapterIndex'] as int? ?? 0,
    sectionIndex: json['sectionIndex'] as int? ?? 0,
    scrollPosition: (json['scrollPosition'] as num?)?.toDouble() ?? 0,
    lastReadAt: json['lastReadAt'] != null && (json['lastReadAt'] as String).isNotEmpty
        ? DateTime.tryParse(json['lastReadAt'] as String)
        : null,
    completed: json['completed'] as bool? ?? false,
  );
}

// ─── CONTENT PROVIDER ───
class ReadingContentProvider {
  static final Map<String, ReadingBook> _books = {};
  static bool _initialized = false;

  /// Load all reading content — call once at startup
  static Future<void> initialize() async {
    if (_initialized) return;
    _buildDefaultContent();
    _initialized = true;
  }

  static List<ReadingBook> get allBooks => _books.values.toList();

  static ReadingBook? getBook(String id) => _books[id];

  static List<ReadingBook> getBooksByCategory(String category) =>
      _books.values.where((b) => b.category == category).toList();

  /// Books for a specific MBTI type
  static List<ReadingBook> getBooksForMbti(String mbti) =>
      _books.values.where((b) => b.mbtiType == mbti.toUpperCase()).toList();

  /// Books for a specific Enneagram type
  static List<ReadingBook> getBooksForEnnea(String ennea) =>
      _books.values.where((b) => b.enneaType == ennea).toList();

  /// Recommended books based on user's types
  static List<ReadingBook> getRecommended(String? mbti, String? ennea) {
    final result = <ReadingBook>[];
    if (mbti != null) result.addAll(getBooksForMbti(mbti));
    if (ennea != null) result.addAll(getBooksForEnnea(ennea));
    // Add universal growth books
    result.addAll(getBooksByCategory('Growth'));
    return result.toSet().toList();
  }

  static void _buildDefaultContent() {
    // ═══════════════════════════════════════════════
    // ENFJ — 高級KAM L
    // ═══════════════════════════════════════════════
    _addBook(ReadingBook(
      id: 'enfj',
      title: '高級KAM L',
      subtitle: 'ENFJ — 用溫暖改變世界嘅領袖',
      emoji: '🌟',
      category: 'MBTI',
      mbtiType: 'ENFJ',
      coverColor: '0xFF9B72AA',
      chapters: [
        ReadingChapter(id: 'enfj-ch1', title: '認識ENFJ', emoji: '🧠', sections: [
          ReadingSection(id: 'enfj-s1', title: 'ENFJ係點樣嘅人？', content: '''
🌟 **ENFJ — 高級KAM L**

朋友形容佢：「佢好似有一種超能力，總係知道你需要啲乜。」

💭 **核心特質：**
• 👑 天生領袖氣場 — 唔係靠惡，而係用魅力同同理心感染人
• 💛 超強直覺 — 你未開口佢已經知你想講乜
• 🎯 使命感驅動 — 佢唔係淨係想做成功，佢想改變世界
• 🔥 熱情如火 — 鍾意嘅嘢可以做到唔瞓唔食

🌈 **佢嘅世界觀：**
「每個人都有潛能，我只係想幫佢哋發掘出嚟。」

⚡ **能量來源：**
同人深度連結、幫人成長、見到自己嘅影響力

🌙 **佢嘅陰暗面：**
太在意人哋點睇佢、唔識Say No、攰到爆都死撐
'''),
          ReadingSection(id: 'enfj-s2', title: 'ENFJ嘅溝通模式', content: '''
💬 **ENFJ點樣同人溝通？**

🗣️ **溝通風格：**
• 🎭 氛圍感知者 — 一入房就感覺到氣氛有冇問題
• 💝 滋養型溝通 — 「你點諗？」「你覺得點？」成日掛喺口邊
• 🎪 社交萬能插蘇 — 去邊都識到朋友，仲要係真心朋友
• 🤝 調和者直覺 — 見到有人爭拗會好唔舒服，想即刻做和事佬

🚫 **溝通地雷：**
• 冷漠無視 — 係ENFJ最大嘅死穴
• 表面化交流 — 「最近點呀？」「幾好」咁樣會令佢好失落
• 唔俾feedback — ENFJ需要知道你嘅感受

💡 **同ENFJ溝通嘅小貼士：**
1. 真誠地表達你嘅感謝 — 佢會記住好耐
2. 有咩直接講 — 佢接受到constructive feedback
3. 俾佢知道你喺度 — ENFJ最怕孤軍作戰
4. 記得問返佢：「你又點呀？」
'''),
        ]),
        ReadingChapter(id: 'enfj-ch2', title: 'ENFJ嘅成長路徑', emoji: '🌱', sections: [
          ReadingSection(id: 'enfj-s3', title: '由People Pleaser到真實領袖', content: '''
🌱 **ENFJ成長路徑：由People Pleaser到真實領袖**

🎯 **階段一：覺察 — 「我係咪太在意人哋點睇我？」**
• 留意自己幾時會自動mode變咗「討好模式」
• 每日問自己一句：「我而家做緊嘅嘢，係咪出自真心？」
• 📝 練習：寫低今日有邊幾次你因為怕人唔開心而委屈自己

💪 **階段二：設立界線 — 「我都可以有極限」**
• 🌊 學習講「我今日唔得閒」
• 🛑 唔再自動回覆every message
• ⏰ 俾自己每日30分鐘「Me Time」
• 📍 小練習：今日試吓唔應機三個鐘

🔥 **階段三：從外求到內求**
• 🔄 將「佢哋覺得我點」轉為「我覺得自己點」
• 🎨 發展你嘅Ti（內向思考）— 停一停，問自己「我點諗？」
• 💎 明白你嘅價值唔來自於你幫咗幾多人
• 🌟 練習：唔靠任何人讚美，做一件令自己驕傲嘅事

🎭 **階段四：擁抱陰影**
• 🌑 ENFJ嘅陰影係ISTP — 有時你需要抽離、冷靜、獨處
• ⚙️ 學習享受一個人的時間
• 🛠️ 發展你嘅 practicality
• 🧘 練習：每個星期抽半日做你自己想做嘅嘢
'''),
        ]),
      ],
    ));

    // ═══════════════════════════════════════════════
    // INFJ — 靈性導師
    // ═══════════════════════════════════════════════
    _addBook(ReadingBook(
      id: 'infj',
      title: '靈性導師',
      subtitle: 'INFJ — 用直覺看透世界嘅夢想家',
      emoji: '🌙',
      category: 'MBTI',
      mbtiType: 'INFJ',
      coverColor: '0xFF5B4A8A',
      chapters: [
        ReadingChapter(id: 'infj-ch1', title: '認識INFJ', emoji: '🧠', sections: [
          ReadingSection(id: 'infj-s1', title: 'INFJ係點樣嘅人？', content: '''
🌙 **INFJ — 靈性導師**

朋友形容佢：「佢好似睇穿咗你，但你完全唔介意。」

💭 **核心特質：**
• 🔮 超強直覺 — 你未諗完佢已經知道結果
• 💭 深度思考者 — 表面平靜，內心波濤洶湧
• 🎯 理想主義 — 唔係淨係想世界變好，佢係真係會去做
• 🌊 情緒深海 — 感受比普通人深十倍

🌈 **佢嘅世界觀：**
「世上冇真正的陌生人，只有未認識嘅朋友。」

⚡ **能量來源：**
深度對話、創作、幫助人成長、獨處時間

🌙 **佢嘅陰暗面：**
太理想化、容易burnout、覺得冇人明佢
'''),
        ]),
      ],
    ));

    // ═══════════════════════════════════════════════
    // INTJ — 戰略家
    // ═══════════════════════════════════════════════
    _addBook(ReadingBook(
      id: 'intj',
      title: '戰略家',
      subtitle: 'INTJ — 用策略征服世界嘅獨立思考者',
      emoji: '♟️',
      category: 'MBTI',
      mbtiType: 'INTJ',
      coverColor: '0xFF2D3A4A',
      chapters: [
        ReadingChapter(id: 'intj-ch1', title: '認識INTJ', emoji: '🧠', sections: [
          ReadingSection(id: 'intj-s1', title: 'INTJ係點樣嘅人？', content: '''
♟️ **INTJ — 戰略家**

朋友形容佢：「佢好似永遠比人行快三步。」

💭 **核心特質：**
• 🎯 目標為本 — 做每一件事都有原因
• 🧠 系統思維 — 睇到成個圖像，唔係淨係一點
• 🔍 完美主義 — 唔係要求完美，係要求卓越
• 🤫 獨立自主 — 最唔鍾意人管佢

🌈 **佢嘅世界觀：**
「如果冇Plan B，即係你仲未plan好。」

⚡ **能量來源：**
達成目標、學習新知識、獨處思考、解決複雜問題

🌙 **佢嘅陰暗面：**
太苛刻、忽略人情世故、容易變成工作狂
'''),
        ]),
      ],
    ));

    // ═══════════════════════════════════════════════
    // Growth — 成長系列
    // ═══════════════════════════════════════════════
    _addBook(ReadingBook(
      id: 'growth-shadow',
      title: '擁抱你的陰影',
      subtitle: 'Shadow Work入門指南',
      emoji: '🌑',
      category: 'Growth',
      coverColor: '0xFF3D2A1A',
      chapters: [
        ReadingChapter(id: 'gs-ch1', title: '什麼是陰影？', emoji: '🌑', sections: [
          ReadingSection(id: 'gs-s1', title: '認識你的陰影自我', content: '''
🌑 **認識你的陰影自我**

🔮 **陰影係咩？**
每個人都有自己唔願意面對嘅部分 — 憤怒、嫉妒、懶惰、自私。
呢啲就係心理學家榮格所講嘅「陰影」（Shadow）。

💭 **陰影唔係敵人：**
• 🌊 壓抑嘅情緒最終會爆發
• 🎭 你越唔想承認嘅特質，越會影響你
• 🔄 接納陰影 = 完整自己
• 💎 陰影裡面藏住你未發掘嘅力量

📝 **小練習：**
諗吓人哋成日激嬲你嘅特質，呢啲好可能就係你拒絕承認嘅部分。
'''),
          ReadingSection(id: 'gs-s2', title: '陰影點樣影響你？', content: '''
🌊 **陰影點樣影響你嘅日常？**

🎪 **投射機制：**
當你強烈討厭某人某特質，好可能呢個特質你都擁有，只係你唔敢承認。

😤 **常見例子：**
• 成日覺得人自私 → 可能你唔敢為自己爭取
• 好憎人扮嘢 → 可能你太在意人點睇你
• 頂唔順人懶散 → 可能你好驚自己放鬆落嚟

💡 **陰影嘅正面力量：**
• 憤怒可以轉化為界線
• 嫉妒可以話俾你知你真係想要啲乜
• 懶惰可能係身體叫你休息嘅訊號

🌈 **接納練習：**
今日留意自己最強烈嘅負面情緒，問吓自己：
「呢個情緒想話俾我知啲乜？」
'''),
        ]),
      ],
    ));

    _addBook(ReadingBook(
      id: 'growth-selflove',
      title: '自我慈悲練習',
      subtitle: '學會對自己溫柔啲',
      emoji: '💖',
      category: 'Growth',
      coverColor: '0xFFE0785A',
      chapters: [
        ReadingChapter(id: 'gs2-ch1', title: '為什麼要自我慈悲？', emoji: '💭', sections: [
          ReadingSection(id: 'gs2-s1', title: '對自己溫柔的力量', content: '''
💖 **對自己溫柔的力量**

🎭 **你對自己苛刻嗎？**
• 做錯少少嘢就鬧自己「廢」
• 覺得自己唔夠好、唔夠努力
• 成日同人比較，覺得自己輸晒

🌸 **自我慈悲（Self-Compassion）三步曲：**

1️⃣ **正念（Mindfulness）**
   👁️ 承認而家嘅感受：「我而家好失望、好沮喪」
   唔好逃避，唔好壓抑，就係靜靜咁承認佢

2️⃣ **共通人性（Common Humanity）**
   🤝 「原來唔止我一個會咁」
   記住：所有人都會失敗、都會痛、都會覺得自己唔夠好

3️⃣ **善待自己（Self-Kindness）**
   💆 問吓自己：「如果我最好嘅朋友遇到呢件事，我會點同佢講？」
   然後用同一種語氣同自己講

📝 **今日練習：**
將手放喺心口，同自己講：
「而家呢一刻好難捱，但我會陪住自己渡過。」
'''),
        ]),
      ],
    ));

    // ═══════════════════════════════════════════════
    // Remaining MBTI types (簡化版)
    // ═══════════════════════════════════════════════
    final mbtiBooks = [
      _mbtiBook('entj', '指揮官', 'ENTJ — 天生領袖，目標為本', '👑', '0xFFD4380D', [
        ('entj-ch1', '認識ENTJ', '🧠', [
          ('entj-s1', 'ENTJ係點樣嘅人？', '''
👑 **ENTJ — 指揮官**

💭 **核心特質：**
• 🎯 目標機器 — 見到目標就會全力衝刺
• 👑 天生領袖 — 唔係想做大佬，係覺得自己應該做
• 🧠 策略思維 — 永遠諗緊下一步、下下一步
• ⚡ 行動力爆棚 — 諗到就做，唔浪費時間

🌈 **世界觀：**
「唔好同我講理由，同我講結果。」
'''),
        ]),
      ]),
      _mbtiBook('enfp', '快樂小狗', 'ENFP — 熱情奔放，創意無限', '🌈', '0xFFD4A843', [
        ('enfp-ch1', '認識ENFP', '🦋', [
          ('enfp-s1', 'ENFP係點樣嘅人？', '''
🌈 **ENFP — 快樂小狗**

💭 **核心特質：**
• 🦋 自由靈魂 — 最怕被框死
• 💡 創意泉源 — 諗嘢永遠跳出框框
• 🔥 熱情如火 — 鍾意嘅人可以好瘋狂
• 🤗 人見人愛 — 社交場合永遠嘅焦點

🌈 **世界觀：**
「人生太短，唔好浪費喺唔開心嘅嘢上面。」
'''),
        ]),
      ]),
      _mbtiBook('infp', '夢想家', 'INFP — 內心豐富，理想至上', '🌙', '0xFF6B5B95', [
        ('infp-ch1', '認識INFP', '🌈', [
          ('infp-s1', 'INFP係點樣嘅人？', '''
🌙 **INFP — 夢想家**

💭 **核心特質：**
• 🌈 理想主義者 — 相信世界可以更好
• 📖 內心世界豐富 — 腦入面有個宇宙
• 🎨 創意表達者 — 用藝術、文字表達自己
• 💭 深度思考者 — 表面平靜，內心波濤洶湧

🌈 **世界觀：**
「最重要係忠於自己。」
'''),
        ]),
      ]),
      _mbtiBook('entp', '挑戰者', 'ENTP — 辯論高手，創新先鋒', '💡', '0xFF7B5EA7', [
        ('entp-ch1', '認識ENTP', '⚡', [
          ('entp-s1', 'ENTP係點樣嘅人？', '''
💡 **ENTP — 挑戰者**

💭 **核心特質：**
• ⚡ 思維速度爆燈 — 諗嘢快到人哋跟唔上
• 🎯 辯論愛好者 — 唔係要贏，係要探索
• 🔄 靈活多變 — 計劃永遠赶不上變化
• 💡 創意思維 — 睇到其他人睇唔到嘅可能性

🌈 **世界觀：**
「規則係俾人打破嘅。」
'''),
        ]),
      ]),
      _mbtiBook('intp', '思考者', 'INTP — 邏輯至上，知識追求者', '🔍', '0xFF4A4A6A', [
        ('intp-ch1', '認識INTP', '🔬', [
          ('intp-s1', 'INTP係點樣嘅人？', '''
🔍 **INTP — 思考者**

💭 **核心特質：**
• 🧠 分析機器 — 見到乜都想拆解
• 📚 知識狂熱者 — 學習係最大樂趣
• 🔍 邏輯至上 — 情感排第二
• 🤔 思考深入 — 一個問題可以諗到天光

🌈 **世界觀：**
「所有嘢都應該有邏輯解釋。」
'''),
        ]),
      ]),
      _mbtiBook('esfj', '社群心臟', 'ESFJ — 溫暖體貼，照顧者', '🤝', '0xFF7FA87A', [
        ('esfj-ch1', '認識ESFJ', '🤝', [
          ('esfj-s1', 'ESFJ係點樣嘅人？', '''
🤝 **ESFJ — 社群心臟**

💭 **核心特質：**
• 💛 溫暖體貼 — 永遠記得你講過嘅嘢
• 🤝 社交專家 — 成個社群嘅連結中心
• 📋 組織能力強 — 活動策劃達人
• 💝 照顧者心態 — 見到人開心佢就開心

🌈 **世界觀：**
「大家好先係真好。」
'''),
        ]),
      ]),
      _mbtiBook('isfj', '守護者', 'ISFJ — 默默付出，可靠支柱', '🛡️', '0xFF6B8E6B', [
        ('isfj-ch1', '認識ISFJ', '🛡️', [
          ('isfj-s1', 'ISFJ係點樣嘅人？', '''
🛡️ **ISFJ — 守護者**

💭 **核心特質：**
• 🛡️ 可靠支柱 — 承諾咗就一定做到
• 💝 默默付出 — 唔需要掌聲
• 📋 細心周到 — 你想唔到嘅佢都幫你想好
• 🌳 穩定力量 — 暴風雨中嘅安定劑

🌈 **世界觀：**
「行動比說話更有力量。」
'''),
        ]),
      ]),
      _mbtiBook('estj', '執行者', 'ESTJ — 效率至上，行動派', '📋', '0xFF8B5E3C', [
        ('estj-ch1', '認識ESTJ', '📋', [
          ('estj-s1', 'ESTJ係點樣嘅人？', '''
📋 **ESTJ — 執行者**

💭 **核心特質：**
• 🎯 效率女王/王 — 最憎浪費時間
• 📋 組織達人 — 冇佢搞唔掂嘅project
• 👑 傳統守護者 — 尊重規則同程序
• 💪 行動為本 — 講多無謂，行動最實際

🌈 **世界觀：**
「冇執行力嘅計劃只係幻想。」
'''),
        ]),
      ]),
      _mbtiBook('istj', '可靠支柱', 'ISTJ — 實事求是，穩如泰山', '⚖️', '0xFF5A5A5A', [
        ('istj-ch1', '認識ISTJ', '⛰️', [
          ('istj-s1', 'ISTJ係點樣嘅人？', '''
⚖️ **ISTJ — 可靠支柱**

💭 **核心特質：**
• ⛰️ 穩如泰山 — 任何情況下都靠得住
• 📋 細節控 — 完美主義嘅執行者
• ⚖️ 公平正義 — 規則就係規則
• 💪 責任感爆棚 — assigned咗嘅任務一定完成

🌈 **世界觀：**
「羅馬唔係一日建成嘅。」
'''),
        ]),
      ]),
      _mbtiBook('esfp', '派對靈魂', 'ESFP — 活潑開朗，及時行樂', '🎉', '0xFFE8785A', [
        ('esfp-ch1', '認識ESFP', '🎉', [
          ('esfp-s1', 'ESFP係點樣嘅人？', '''
🎉 **ESFP — 派對靈魂**

💭 **核心特質：**
• 🎭 表演慾強 — 成個世界係佢嘅舞台
• 🔥 活在當下 — 唔會諗太遠
• 🤗 魅力四射 — 身邊永遠有人
• 🎪 氣氛製造機 — 有佢喺度就唔會悶

🌈 **世界觀：**
「人生得一場，點可以唔盡興？」
'''),
        ]),
      ]),
      _mbtiBook('isfp', '藝術家', 'ISFP — 溫柔敏感，美學靈魂', '🎨', '0xFF8B6B8B', [
        ('isfp-ch1', '認識ISFP', '🎨', [
          ('isfp-s1', 'ISFP係點樣嘅人？', '''
🎨 **ISFP — 藝術家**

💭 **核心特質：**
• 🎨 美學觸覺 — 所有靚嘢都逃唔過佢對眼
• 🌊 情感細膩 — 感受比說話多
• 🧘 隨遇而安 — 唔鍾意計劃，鍾意隨心
• 💭 內向敏感 — 表面平靜，內心豐富

🌈 **世界觀：**
「美就係真理。」
'''),
        ]),
      ]),
      _mbtiBook('estp', '冒險家', 'ESTP — 行動派，冒險家', '🚀', '0xFFD4783C', [
        ('estp-ch1', '認識ESTP', '🏄', [
          ('estp-s1', 'ESTP係點樣嘅人？', '''
🚀 **ESTP — 冒險家**

💭 **核心特質：**
• 🏄 行動力MAX — 諗到就做，唔會猶豫
• 🎯 機會獵人 — 永遠喺度搵下一個機會
• 🔥 魅力型冒險家 — 人哋跟住佢冒險
• 💪 危機處理高手 — 越緊急越冷靜

🌈 **世界觀：**
「你唔試過點知唔得？」
'''),
        ]),
      ]),
      _mbtiBook('istp', '工匠', 'ISTP — 冷靜實幹，解決問題', '🔧', '0xFF5A6A6A', [
        ('istp-ch1', '認識ISTP', '🔧', [
          ('istp-s1', 'ISTP係點樣嘅人？', '''
🔧 **ISTP — 工匠**

💭 **核心特質：**
• 🔧 動手能力強 — 見到問題就想拆解
• 🧘 冷靜分析 — 任何情況都唔會慌
• 🏔️ 獨立自主 — 最鍾意一個人搞掂
• 🎯 實用主義 — 有用先係真理

🌈 **世界觀：**
「唔好講咁多，show me。」
'''),
        ]),
      ]),
    ];

    for (final book in mbtiBooks) {
      _addBook(book);
    }
  }

  static void _addBook(ReadingBook book) {
    _books[book.id] = book;
  }

  static ReadingBook _mbtiBook(
    String id,
    String title,
    String subtitle,
    String emoji,
    String color,
    List<(String, String, String, List<(String, String, String)>)> chapters,
  ) {
    return ReadingBook(
      id: id,
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      category: 'MBTI',
      mbtiType: id.toUpperCase(),
      coverColor: color,
      chapters: chapters.map((ch) => ReadingChapter(
        id: ch.$1,
        title: ch.$2,
        emoji: ch.$3,
        sections: ch.$4.map((s) => ReadingSection(
          id: s.$1,
          title: s.$2,
          content: s.$3,
        )).toList(),
      )).toList(),
    );
  }
}
