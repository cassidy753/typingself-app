import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../daily_quote/zodiac_service.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Greeting Header ──
          _GreetingHeader(mbti: widget.mbti, ennea: widget.ennea),

          const SizedBox(height: 16),

          // ── 📖 是日金句 ──
          _Pill('📖 是日金句', accent: widget.accent, accentBg: widget.accentBg),
          const SizedBox(height: 10),
          _QuoteCard(accent: widget.accent),

          const SizedBox(height: 16),

          // ── 💬 你嘅人格對朋友講嘅說話 ──
          _Pill('💬 你嘅人格對朋友講嘅說話', accent: widget.accent, accentBg: widget.accentBg),
          const SizedBox(height: 10),
          _PersonalizedQuote(mbti: widget.mbti, ennea: widget.ennea, accent: widget.accent),

          const SizedBox(height: 16),

          // ── 🧭 自我認識旅程 ──
          _Pill('🧭 自我認識旅程', accent: widget.accent, accentBg: widget.accentBg),
          const SizedBox(height: 10),
          _JourneyProgress(
            testDone: _testDone,
            shadowDone: _shadowDone,
            accent: widget.accent,
            accentBg: widget.accentBg,
          ),

          const SizedBox(height: 16),

          // ── 心情 ──
          _MoodSection(accent: widget.accent, accentBg: widget.accentBg),

          const SizedBox(height: 16),

          // ── 星座 ──
          _ZodiacMini(zodiac: _zodiac, dayOfYear: dayOfYear, accent: widget.accent, accentBg: widget.accentBg),

          const SizedBox(height: 16),

          const SizedBox(height: 32),
        ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ── TS brand icon: gradient purple-pink circle with "TS" ──
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFFFF6B9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text('TS', style: GoogleFonts.notoSansTc(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.5,
              )),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting，$name',
                  style: GoogleFonts.notoSerifTc(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('$mbti · $ennea',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

// ── Section Pill ──
class _Pill extends StatelessWidget {
  final String text;
  final Color accent, accentBg;
  const _Pill(this.text, {required this.accent, required this.accentBg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('❝', style: TextStyle(fontSize: 28, color: accent.withValues(alpha: 0.15), fontFamily: 'Noto Serif TC', height: 0.5)),
          const SizedBox(height: 6),
          Text('怯？你就輸一世。', textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 4),
          Text('— 嚦咕嚦咕新年財', style: GoogleFonts.notoSansTc(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
          const SizedBox(height: 10),
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (i) => Padding(
          padding: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(phrases[i], style: GoogleFonts.notoSerifTc(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.share, size: 16, color: accent),
                  onPressed: () => Share.share('「${phrases[i]}」\n\n— 型得你 @typingself\n了解你嘅 MBTI 人格：https://xingdeni.app'),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _StageRow(0, '🧠', 'Stage 1', 'MBTI + Enneagram', testDone, accent, accentBg),
          const SizedBox(height: 8),
          _StageRow(1, '🌑', 'Stage 2', 'Shadow Report', shadowDone, accent, accentBg),
          const SizedBox(height: 8),
          _StageRow(2, '🌱', 'Stage 3', 'Growth Plan', false, accent, accentBg, locked: !shadowDone),
          const SizedBox(height: 8),
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
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF8FA87A).withValues(alpha: 0.15) : accentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(done ? '✅' : (locked ? '🔒' : emoji), style: TextStyle(fontSize: done ? 14 : 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (done)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF8FA87A).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Text('完成', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF8FA87A))),
            )
          else if (locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
              child: Text('未解鎖', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
              child: Text('進行中', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: widget.accentBg, borderRadius: BorderRadius.circular(10)),
                child: Text('心情', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: widget.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Horizontal bar track with 5 dots ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final isSelected = _selected == i;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? widget.accent : widget.accent.withValues(alpha: 0.12),
                    border: isSelected
                        ? Border.all(color: widget.accent, width: 2)
                        : Border.all(color: widget.accent.withValues(alpha: 0.2)),
                  ),
                  child: isSelected
                      ? Center(child: Icon(Icons.favorite, size: 16, color: Colors.white))
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // ── Mood labels ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('😊 開心', style: TextStyle(fontSize: 10, color: _selected != null && _selected! <= 1 ? widget.accent : AppColors.textMuted)),
              Text('😐 普通', style: TextStyle(fontSize: 10, color: _selected == 2 ? widget.accent : AppColors.textMuted)),
              Text('😤 生氣', style: TextStyle(fontSize: 10, color: _selected != null && _selected! >= 3 ? widget.accent : AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(_selected != null ? _moodLabel(_selected!) : '㩒一下記錄今日心情',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _moodLabel(int i) {
    if (i <= 1) return '今日心情：開心 😊';
    if (i == 2) return '今日心情：普通 😐';
    return '今日心情：生氣 😤';
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(10)),
                child: Text('運程', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Text(sign, style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(horoscope, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 6),
          Text('設定星座 → 我嘅', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
