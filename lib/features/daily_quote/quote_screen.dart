// ═══════════════════════════════════════════════════════════════════════
// HomeScreen (formerly QuoteScreen) — Edition 2 Redesign
// 4 vertically stacked sections:
//   1. Type Card — shows test placeholder or type details
//   2. 今日金句 — daily quote with share
//   3. 內心心聲 — 3 phrases per type or prompt to start test
//   4. 運程 — sun + moon sign horoscope
// Gradient bg · Daebi palette frosted cards · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../daily_quote/zodiac_service.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/decision_tree_engine.dart';
import '../settings/settings_screen.dart';

// ─── MBTI emoji map (16 types) ───
const Map<String, String> _mbtiEmoji = {
  'ENFJ': '🦋', 'INFJ': '🌌', 'INTJ': '🧠', 'ENTJ': '👑',
  'ENFP': '🌈', 'INFP': '🌙', 'ENTP': '⚡', 'INTP': '🔬',
  'ESFJ': '🤝', 'ISFJ': '🛡️', 'ESTJ': '📋', 'ISTJ': '⛰️',
  'ESFP': '🎉', 'ISFP': '🎨', 'ESTP': '🏄', 'ISTP': '🔧',
};

// ─── Cantonese type names ───
const Map<String, String> _mbtiNames = {
  'ENFJ': '高級KAM L', 'INFJ': '靈性導師', 'INTJ': '戰略家', 'ENTJ': '指揮官',
  'ENFP': '快樂小狗', 'INFP': '夢想家', 'ENTP': '挑戰者', 'INTP': '思考者',
  'ESFJ': '社群心臟', 'ISFJ': '守護者', 'ESTJ': '執行者', 'ISTJ': '可靠支柱',
  'ESFP': '派對靈魂', 'ISFP': '藝術家', 'ESTP': '冒險家', 'ISTP': '工匠',
};

// ─── Reusable card style ───
BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.surface.withValues(alpha: 0.88),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ],
);

// ─── Inner voice phrases per MBTI type ───
const Map<String, List<String>> _innerVoice = {
  'ENFJ': ['我都有攰嘅一日，可唔可以俾我唞吓？', '你開心我就開心，但你都要開心先得㗎', '我有時都好想有人主動關心吓我'],
  'INFJ': ['我感受到你嘅情緒，但有時我都需要空間', '我唔係冷漠，我只係需要時間諗嘢', '你見到嘅我只係冰山一角'],
  'INTJ': ['我唔係串，我只係覺得效率重要啲', '可唔可以俾我專心做完先？', '我嘅沉默唔代表我冇嘢想講'],
  'ENTJ': ['我唔係想鬧你，我只係想快啲搞掂', '你明唔明我壓力有幾大？', '我都想有人話俾我聽「你做得好」'],
  'ENFP': ['我笑面迎人，但我都有喊嘅時候', '我成日約你，但你有幾可主動搵我？', '我嘅熱情唔係應份㗎'],
  'INFP': ['你睇我好開心，其實我諗好多嘢', '我唔係頹，我只係活喺自己嘅世界', '你唔需要明白我全部，但請你尊重我'],
  'ENTP': ['我駁嘴係因為我有興趣同你傾', '可唔可以俾我講完先？我仲未講完', '你覺得我玩世不恭，其實我睇得好通透'],
  'INTP': ['我唔係唔理你，我只係諗緊嘢', '你問我「諗緊咩」嘅時候，我唔知點答你', '我覺得有趣嘅嘢，你未必明'],
  'ESFJ': ['我記得你所有喜好，你記唔記得我嘅？', '冇人幫手嘅時候，次次都係我做晒', '我都想有人照顧吓我'],
  'ISFJ': ['我唔介意幫你，但我都有自己嘅嘢要做', '我記得嘅細節，你永遠唔會留意到', '我付出咗好多，只係我唔出聲'],
  'ESTJ': ['我話你係因為我想你好', '效率唔係一切，但有問題咩？', '我都想放鬆，但我放鬆咗邊個做嘢？'],
  'ISTJ': ['我照規矩做唔代表我冇創意', '我應承得你嘅就一定做到', '我唔係悶，我只係穩陣'],
  'ESFP': ['我成日笑，但唔代表我冇煩惱', '你覺得我貪玩，其實我係享受生活', '我帶歡樂俾你，你有幾可關心我感受？'],
  'ISFP': ['我唔出聲唔代表我冇意見', '你覺得我怪？我覺得你先怪', '我嘅作品就係我嘅語言'],
  'ESTP': ['我唔係衝動，我只係行動快過你諗嘢', '你覺得我冒險，我覺得你浪費時間', '當下唔做，等幾時？'],
  'ISTP': ['我唔係冷漠，我只係用行動表達', '你講咁多，不如直接做啦', '我自己搞得掂，唔使擔心'],
};

// ─── Moon sign offsets (rough approximation for daily use) ───
String _moonSign(String sunSign) {
  final idx = ZodiacService.signs.indexOf(sunSign);
  if (idx == -1) return sunSign;
  // Moon sign shifts ~1 sign every 2.5 days — use day of year for determinism
  final day = DateTime.now().day;
  final moonIdx = (idx + (day % 7)) % ZodiacService.signs.length;
  return ZodiacService.signs[moonIdx];
}

// ═══════════════════════════════════════════════════════════════════════
// HomeScreen
// ═══════════════════════════════════════════════════════════════════════

class QuoteScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String? mbti;
  final String? ennea;
  const QuoteScreen({super.key, required this.accent, required this.accentBg, this.mbti, this.ennea});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  bool _testDone = false;
  String? _zodiac;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final testDone = prefs.getBool('test_done') ?? false;
    final zodiac = prefs.getString('zodiac');

    if (!mounted) return;
    setState(() {
      _testDone = testDone;
      _zodiac = zodiac;
    });
  }

  void _startTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssessmentIntroScreen(
          engine: DecisionTreeEngine(),
          onComplete: (mbti, ennea) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('mbti', mbti);
              prefs.setString('ennea', ennea);
              prefs.setBool('test_done', true);
            });
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              setState(() => _testDone = true);
            }
          },
        ),
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早晨';
    if (hour < 18) return '你好';
    return '夜晚';
  }

  String? get _cantoName {
    final m = widget.mbti;
    if (m != null && _testDone) return _mbtiNames[m] ?? '你';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0E6F6), // soft lavender
            Color(0xFFFFEDE8), // soft coral/peach
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),

            // ── Greeting Header ──
            _GreetingHeader(
              greeting: _greeting,
              name: _cantoName ?? '你',
              hasTest: _testDone,
              mbti: widget.mbti,
              ennea: widget.ennea,
            ),

            const SizedBox(height: 20),

            // ── 1. Type Card ──
            _TypeCard(
              testDone: _testDone,
              mbti: widget.mbti,
              ennea: widget.ennea,
              accent: widget.accent,
              accentBg: widget.accentBg,
              onStartTest: _startTest,
            ),

            const SizedBox(height: 24),

            // ── 2. 今日金句 ──
            _SectionHeader('📖 今日金句', accent: widget.accent, accentBg: widget.accentBg),
            const SizedBox(height: 12),
            _QuoteCard(accent: widget.accent),

            const SizedBox(height: 24),

            // ── 3. 內心心聲 ──
            _SectionHeader('💬 內心心聲', accent: widget.accent, accentBg: widget.accentBg),
            const SizedBox(height: 12),
            _InnerVoiceCard(
              testDone: _testDone,
              mbti: widget.mbti,
              accent: widget.accent,
              onStartTest: _startTest,
            ),

            const SizedBox(height: 24),

            // ── 4. 運程 ──
            _SectionHeader('🌟 運程', accent: widget.accent, accentBg: widget.accentBg),
            const SizedBox(height: 12),
            _HoroscopeCard(
              zodiac: _zodiac,
              accent: widget.accent,
              accentBg: widget.accentBg,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Greeting Header
// ═══════════════════════════════════════════════════════════════════════

class _GreetingHeader extends StatelessWidget {
  final String greeting, name;
  final bool hasTest;
  final String? mbti, ennea;

  const _GreetingHeader({
    required this.greeting,
    required this.name,
    required this.hasTest,
    this.mbti,
    this.ennea,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // ── TS brand icon ──
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFFFF6B9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text('TS', style: GoogleFonts.notoSansTc(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.5,
              )),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting，$name',
                  style: GoogleFonts.notoSerifTc(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                if (hasTest && mbti != null && ennea != null)
                  Text('$mbti · $ennea',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500))
                else
                  const Text('你未完成測驗',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Section Header
// ═══════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String text;
  final Color accent, accentBg;
  const _SectionHeader(this.text, {required this.accent, required this.accentBg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Text(text, style: GoogleFonts.notoSansTc(
        fontSize: 15, fontWeight: FontWeight.w700, color: accent,
        letterSpacing: 0.3,
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 1. Type Card
// ═══════════════════════════════════════════════════════════════════════

class _TypeCard extends StatelessWidget {
  final bool testDone;
  final String? mbti;
  final String? ennea;
  final Color accent, accentBg;
  final VoidCallback onStartTest;

  const _TypeCard({
    required this.testDone,
    this.mbti,
    this.ennea,
    required this.accent,
    required this.accentBg,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    if (!testDone) {
      return _PlaceholderTypeCard(accent: accent, onStartTest: onStartTest);
    }
    final m = mbti ?? 'ENFJ';
    final e = ennea ?? '5w4';
    final name = _mbtiNames[m] ?? '探索者';
    final emoji = _mbtiEmoji[m] ?? '🧠';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.10),
            AppColors.surface.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Emoji ──
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$m · $e',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTypeCard extends StatelessWidget {
  final Color accent;
  final VoidCallback onStartTest;

  const _PlaceholderTypeCard({
    required this.accent,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // ── Placeholder icon ──
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text('❓', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '有待測驗嘅型格',
            style: GoogleFonts.notoSerifTc(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '完成人格測驗，解鎖你嘅 MBTI 類型同專屬分析',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
                textStyle: GoogleFonts.notoSansTc(
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('開始測驗'),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 2. Daily Quote Card
// ═══════════════════════════════════════════════════════════════════════

class _QuoteCard extends StatelessWidget {
  final Color accent;
  const _QuoteCard({required this.accent});

  static const _quotes = [
    ('怯？你就輸一世。', '嚦咕嚦咕新年財'),
    ('做人如果冇夢想，同條鹹魚有咩分別？', '少林足球'),
    ('不如我哋由頭嚟過。', '春光乍洩'),
    ('你有權保持沉默，但你所講嘅將會成為呈堂證供。', '無間道'),
    ('我讀書少，你唔好呃我。', '精武門'),
    ('你越係驚一樣嘢，佢就越係會出現。', '讀心神探'),
    ('人生有幾多個十年？最緊要係痛快！', '巾幗梟雄'),
    ('笑口常開，好彩自然來。', '家有喜事'),
    ('我係差人，我嘅職責係維護法紀。', '無間道'),
    ('每個人都有佢嘅位置，搵到自己嘅路就得。', '少林足球'),
  ];

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now().day;
    final (quote, source) = _quotes[day % _quotes.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Decorative quote mark
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text('❝', style: TextStyle(fontSize: 22, color: accent, fontFamily: 'Noto Serif TC')),
            ),
          ),
          const SizedBox(height: 12),
          Text(quote, textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 8),
          Text('— $source', style: GoogleFonts.notoSansTc(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // ── Share button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Share.share(
                '❝$quote❞ — $source\n\n⬇️ 型得你 — 認識自己嘅第一步',
              ),
              icon: const Icon(Icons.share, size: 16),
              label: const Text('分享金句'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.08),
                foregroundColor: accent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 3. Inner Voice Card
// ═══════════════════════════════════════════════════════════════════════

class _InnerVoiceCard extends StatelessWidget {
  final bool testDone;
  final String? mbti;
  final Color accent;
  final VoidCallback onStartTest;

  const _InnerVoiceCard({
    required this.testDone,
    this.mbti,
    required this.accent,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    if (!testDone) {
      return _PlaceholderVoiceCard(accent: accent, onStartTest: onStartTest);
    }

    final phrases = _innerVoice[mbti] ?? _innerVoice['ENFJ']!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (i) => Padding(
          padding: EdgeInsets.only(bottom: i < 2 ? 14 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number badge
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(child: Text('${i + 1}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withValues(alpha: 0.1)),
                  ),
                  child: Text(phrases[i],
                    style: GoogleFonts.notoSerifTc(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary, height: 1.5,
                    )),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.share, size: 16, color: accent),
                  onPressed: () => Share.share(
                    '「${phrases[i]}」\n\n— 型得你 @typingself\n了解你嘅 MBTI 人格：https://xingdeni.app',
                  ),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  splashRadius: 22,
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class _PlaceholderVoiceCard extends StatelessWidget {
  final Color accent;
  final VoidCallback onStartTest;

  const _PlaceholderVoiceCard({
    required this.accent,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('💭', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 14),
          Text(
            '立即完成測驗，獲取你嘅心聲',
            style: GoogleFonts.notoSerifTc(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '每種人格類型都有佢唔敢講出口嘅心聲，測驗完就會話俾你聽',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
                textStyle: GoogleFonts.notoSansTc(
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('去測驗'),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 4. Horoscope Card
// ═══════════════════════════════════════════════════════════════════════

class _HoroscopeCard extends StatelessWidget {
  final String? zodiac;
  final Color accent, accentBg;

  const _HoroscopeCard({
    this.zodiac,
    required this.accent,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    final hasZodiac = zodiac != null && zodiac!.isNotEmpty;

    if (!hasZodiac) {
      return _NoZodiacPrompt(accent: accent, accentBg: accentBg);
    }

    final sign = zodiac!;
    final emoji = ZodiacService.signEmoji[sign] ?? '♏';
    final dayOfYear = DateTime.now().day; // simplified — use day for deterministic
    final sunHoroscope = ZodiacService.dailyHoroscope(sign, dayOfYear);
    final moon = _moonSign(sign);
    final moonEmoji = ZodiacService.signEmoji[moon] ?? '🌙';
    final moonHoroscope = ZodiacService.dailyHoroscope(moon, dayOfYear + 7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sun sign ──
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Text('太陽 · $sign', style: GoogleFonts.notoSansTc(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.08)),
            ),
            child: Text(sunHoroscope, style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary, height: 1.5,
            )),
          ),

          const SizedBox(height: 16),

          // ── Moon sign ──
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Center(child: Text(moonEmoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Text('月亮 · $moon', style: GoogleFonts.notoSansTc(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.08)),
            ),
            child: Text(moonHoroscope, style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary, height: 1.5,
            )),
          ),

          const SizedBox(height: 12),
          // ── Settings link ──
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      accent: accent,
                      accentBg: accentBg,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('設定星座 →', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: accent,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoZodiacPrompt extends StatelessWidget {
  final Color accent, accentBg;

  const _NoZodiacPrompt({
    required this.accent,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('🌟', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 14),
          Text(
            '立即於設定更新你嘅星座',
            style: GoogleFonts.notoSerifTc(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '設定太陽同月亮星座後，就可以睇到每日專屬運程',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      accent: accent,
                      accentBg: accentBg,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
                textStyle: GoogleFonts.notoSansTc(
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('去設定'),
            ),
          ),
        ],
      ),
    );
  }
}
