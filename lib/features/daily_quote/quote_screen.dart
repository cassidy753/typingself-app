import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../daily_quote/zodiac_service.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/decision_tree_engine.dart';

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

class QuoteScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String mbti;
  final String ennea;
  const QuoteScreen({super.key, required this.accent, required this.accentBg, required this.mbti, required this.ennea});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  bool _testDone = false;
  bool _shadowDone = false;
  String? _zodiac;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _testDone = prefs.getBool('test_done') ?? false;
      _shadowDone = prefs.getBool('shadow_report_viewed') ?? false;
      _zodiac = prefs.getString('zodiac_sign');
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

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
            _GreetingHeader(mbti: widget.mbti, ennea: widget.ennea),

            // ── 🧪 Hero CTA: 人格測驗（未完成時顯示） ──
            if (!_testDone) ...[
              const SizedBox(height: 20),
              _TestPromptCard(accent: widget.accent),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 26),

            // ── 🏠 Section: 是日金句 ──
            _SectionHeader('📖 是日金句', accent: widget.accent, accentBg: widget.accentBg),
            const SizedBox(height: 12),
            _QuoteCard(accent: widget.accent),

            const SizedBox(height: 26),

            // ── 💬 你嘅人格對朋友講嘅說話 ──
            _SectionHeader('💬 你嘅人格對朋友講嘅說話', accent: widget.accent, accentBg: widget.accentBg),
            const SizedBox(height: 12),
            _PersonalizedQuote(mbti: widget.mbti, ennea: widget.ennea, accent: widget.accent),

            const SizedBox(height: 26),

            // ── 🧭 自我認識旅程 ──
            _SectionHeader('🧭 自我認識旅程', accent: widget.accent, accentBg: widget.accentBg),
            const SizedBox(height: 12),
            _JourneyProgress(
              testDone: _testDone,
              shadowDone: _shadowDone,
              accent: widget.accent,
              accentBg: widget.accentBg,
            ),

            const SizedBox(height: 26),

            // ── 心情 ──
            _MoodSection(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 26),

            // ── 星座 ──
            _ZodiacMini(zodiac: _zodiac, dayOfYear: dayOfYear, accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 28),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ──
class _GreetingHeader extends StatelessWidget {
  final String mbti, ennea;
  const _GreetingHeader({required this.mbti, required this.ennea});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? '早晨' : (hour < 18 ? '你好' : '夜晚');
    final name = _getCantoName(mbti);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // ── TS brand icon: gradient purple-pink circle with "TS" ──
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
                Text('$mbti · $ennea',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCantoName(String mbti) {
    switch (mbti) {
      case 'ENFJ': return '高級KAM L';
      case 'INFJ': return '靈性導師';
      case 'INTJ': return '戰略家';
      case 'ENTJ': return '指揮官';
      case 'ENFP': return '快樂小狗';
      case 'INFP': return '夢想家';
      case 'ENTP': return '挑戰者';
      case 'INTP': return '思考者';
      case 'ESFJ': return '社群心臟';
      case 'ISFJ': return '守護者';
      case 'ESTJ': return '執行者';
      case 'ISTJ': return '可靠支柱';
      case 'ESFP': return '派對靈魂';
      case 'ISFP': return '藝術家';
      case 'ESTP': return '冒險家';
      case 'ISTP': return '工匠';
      default: return '探索者';
    }
  }
}

// ── 🧪 Hero CTA: 人格測驗（未完成時顯示） ──
class _TestPromptCard extends StatelessWidget {
  final Color accent;
  const _TestPromptCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEBE0F5), // soft lavender
            const Color(0xFFFFEDE8), // soft coral
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.cta.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cta.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emoji + badge ──
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.cta.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('🧪', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 10),
                Text('人格測驗', style: GoogleFonts.notoSansTc(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.cta,
                )),
              ],
            ),
            const SizedBox(height: 14),

            // ── Title ──
            Text('開始你嘅人格測驗', style: GoogleFonts.notoSerifTc(
              fontSize: 26, fontWeight: FontWeight.w900,
              color: AppColors.textPrimary, height: 1.2,
            )),
            const SizedBox(height: 8),

            // ── Subtitle ──
            Text('了解你嘅 MBTI 同 Enneagram 類型，解鎖完整功能。或者碌落去繼續瀏覽都得～', style: GoogleFonts.notoSansTc(
              fontSize: 14, fontWeight: FontWeight.w400,
              color: AppColors.textSecondary, height: 1.5,
            )),
            const SizedBox(height: 20),

            // ── CTA Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AssessmentIntroScreen(
                        engine: DecisionTreeEngine(),
                        onComplete: (_, __) {},
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                  textStyle: GoogleFonts.notoSansTc(
                    fontSize: 17, fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('開始測驗'),
              ),
            ),
            const SizedBox(height: 10),

            // ── Skip hint ──
            Center(
              child: Text('撳 skip 繼續碌落去睇內容',
                style: GoogleFonts.notoSansTc(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ──
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

// ── Daily Quote Card ──
class _QuoteCard extends StatelessWidget {
  final Color accent;
  const _QuoteCard({required this.accent});

  @override
  Widget build(BuildContext context) {
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
          Text('怯？你就輸一世。', textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 8),
          Text('— 嚦咕嚦咕新年財', style: GoogleFonts.notoSansTc(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // ── Share button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Share.share('❝怯？你就輸一世。❞ — 嚦咕嚦咕新年財\n\n⬇️ 型得你 — 認識自己嘅第一步'),
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

// ── 💬 你嘅人格對朋友講嘅說話 ──
class _PersonalizedQuote extends StatelessWidget {
  final String mbti, ennea;
  final Color accent;
  const _PersonalizedQuote({required this.mbti, required this.ennea, required this.accent});

  @override
  Widget build(BuildContext context) {
    final phrases = _getPhrases(mbti);
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
                child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
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
                  child: Text(phrases[i], style: GoogleFonts.notoSerifTc(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5)),
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
                  onPressed: () => Share.share('「${phrases[i]}」\n\n— 型得你 @typingself\n了解你嘅 MBTI 人格：https://xingdeni.app'),
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  List<String> _getPhrases(String mbti) {
    switch (mbti) {
      case 'ENFJ': return ['你值得擁有最好嘅嘢，唔好俾任何人話你唔夠', '我喺度，你有咩想講就講啦', '你一啲都唔麻煩，你值得被錫'];
      case 'INFJ': return ['你感受到嘅嘢係真實嘅，相信你自己', '唔需要急，你嘅路會慢慢清晰', '我明白你，你唔係孤單一個'];
      case 'INTJ': return ['你有自己嘅節奏，唔使同人比較', '問題係有解決方法嘅，只係未搵到啫', '你嘅分析能力係你嘅武器'];
      case 'ENTJ': return ['你諗到就做到，唔好停', '懶人先會阻住你發達，踢走佢', '目標要定得夠大，你先會去到咁遠'];
      case 'ENFP': return ['你開心就得啦，理得人點諗', '你係世上獨一無二嘅存在', '試咗先講啦，最多咪笑吓'];
      case 'INFP': return ['你嘅內心世界好靚，唔好收埋', '做自己已經足夠', '溫柔都係一種力量'];
      case 'ENTP': return ['你諗嘢咁快，唔好浪費咗佢', '冇人話你一定要跟規矩', '同你傾偈永遠都有新嘢學'];
      case 'INTP': return ['你諗通咗未？分享嚟聽下', '複雜嘅嘢你都可以拆解到', '你唔係怪，你係與眾不同'];
      case 'ESFJ': return ['你對人咁好，都要記得對自己好', '冇你嘅話，成個group都散晒', '你付出咁多，係時候收返啲啦'];
      case 'ISFJ': return ['你照顧人照顧得咁好，辛苦你啦', '你記得所有人嘅喜好，好厲害', '你都值得俾人照顧㗎'];
      case 'ESTJ': return ['搞掂未？搞掂就下一個', '效率就係你嘅超能力', '冇你喺度，啲嘢實亂晒'];
      case 'ISTJ': return ['靠得住嘅人，非你莫屬', '你話得嘅就一定得', '你嘅責任感係你最大嘅優點'];
      case 'ESFP': return ['有你就係party time', '你笑，全世界就跟住你笑', '活在當下，你係大師'];
      case 'ISFP': return ['你嘅美感係冇得輸', '做你喜歡嘅嘢，你就會發光', '你嘅溫柔係世界上最美嘅嘢'];
      case 'ESTP': return ['而家就去做啦，等咩啫', '跟你玩永遠最刺激', '你解決到嘅問題比你想像中多'];
      case 'ISTP': return ['你整到好靚喎，點學㗎？', '同你合作好爽手', '你話唔得嘅時候就真係唔得'];
      default: return ['你值得擁有最好嘅嘢', '做自己已經足夠', '我喺度陪你'];
    }
  }
}

// ── Journey Progress ──
class _JourneyProgress extends StatelessWidget {
  final bool testDone, shadowDone;
  final Color accent, accentBg;
  const _JourneyProgress({required this.testDone, required this.shadowDone, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _StageRow(0, '🧠', 'Stage 1', 'MBTI + Enneagram', testDone, accent, accentBg),
          const SizedBox(height: 10),
          _StageRow(1, '🌑', 'Stage 2', 'Shadow Report', shadowDone, accent, accentBg),
          const SizedBox(height: 10),
          _StageRow(2, '🌱', 'Stage 3', 'Growth Plan', false, accent, accentBg, locked: !shadowDone),
          const SizedBox(height: 10),
          _StageRow(3, '💎', 'Stage 4', 'Integration', false, accent, accentBg, locked: true),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final int stage;
  final String emoji, title, subtitle;
  final bool done;
  final Color accent, accentBg;
  final bool locked;

  const _StageRow(this.stage, this.emoji, this.title, this.subtitle, this.done, this.accent, this.accentBg, {this.locked = false});

  @override
  Widget build(BuildContext context) {
    final opacity = locked ? 0.4 : 1.0;
    return Opacity(
      opacity: opacity,
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF8FA87A).withValues(alpha: 0.15) : accentBg,
              borderRadius: BorderRadius.circular(14),
              border: done
                  ? Border.all(color: const Color(0xFF8FA87A).withValues(alpha: 0.3))
                  : Border.all(color: accent.withValues(alpha: 0.15)),
            ),
            child: Center(child: Text(done ? '✅' : (locked ? '🔒' : emoji), style: TextStyle(fontSize: done ? 16 : 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (done)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF8FA87A).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Text('完成', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8FA87A))),
            )
          else if (locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
              child: Text('未解鎖', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
              child: Text('進行中', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
            ),
        ],
      ),
    );
  }
}

// ── Mood Section ──
class _MoodSection extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  const _MoodSection({required this.accent, required this.accentBg});
  @override
  State<_MoodSection> createState() => _MoodSectionState();
}

class _MoodSectionState extends State<_MoodSection> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final labels = ['☀️ 好好', '🙂 幾好', '😐 普通', '😔 麻麻', '😤 好燥'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header inside card
          _SectionHeader('😊 今日心情', accent: widget.accent, accentBg: widget.accentBg),
          const SizedBox(height: 18),
          // ── Mood dots row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final isSelected = _selected == i;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? widget.accent : widget.accent.withValues(alpha: 0.08),
                    border: Border.all(
                      color: isSelected
                          ? widget.accent
                          : widget.accent.withValues(alpha: 0.15),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: widget.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Center(
                    child: isSelected
                        ? const Icon(Icons.favorite, size: 20, color: Colors.white)
                        : Icon(Icons.favorite_border, size: 18, color: widget.accent.withValues(alpha: 0.4)),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          // ── Mood labels row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) => Text(
              labels[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: _selected == i ? FontWeight.w700 : FontWeight.w500,
                color: _selected == i ? widget.accent : AppColors.textMuted,
              ),
            )),
          ),
          const SizedBox(height: 12),
          // ── Selected mood feedback ──
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selected != null ? widget.accent.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _selected != null ? _moodLabel(_selected!) : '㩒個圓點記錄今日心情',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _selected != null ? widget.accent : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moodLabel(int i) {
    switch (i) {
      case 0: return '今日心情好好 ☀️';
      case 1: return '今日心情幾好 🙃';
      case 2: return '今日心情普通 😐';
      case 3: return '今日心情麻麻 😔';
      case 4: return '今日心情好燥 😤';
      default: return '今日心情：—';
    }
  }
}

// ── Zodiac Mini ──
class _ZodiacMini extends StatelessWidget {
  final String? zodiac;
  final int dayOfYear;
  final Color accent, accentBg;
  const _ZodiacMini({required this.zodiac, required this.dayOfYear, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    final sign = zodiac ?? '天蠍';
    final emoji = ZodiacService.signEmoji[sign] ?? '♏';
    final horoscope = ZodiacService.dailyHoroscope(sign, dayOfYear);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _SectionHeader('🌟 今日運程', accent: accent, accentBg: accentBg),
          const SizedBox(height: 16),
          // Sign row
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Text(sign, style: GoogleFonts.notoSansTc(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          // Horoscope text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.08)),
            ),
            child: Text(horoscope, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          ),
          const SizedBox(height: 10),
          // Settings link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('設定星座 →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: accent)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
