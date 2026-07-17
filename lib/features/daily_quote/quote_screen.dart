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

          // ── ✨ 屬於你嘅語句 ──
          _Pill('✨ 屬於你嘅語句', accent: widget.accent, accentBg: widget.accentBg),
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

          // ── 心情 & 星座 ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _MoodSection(accent: widget.accent, accentBg: widget.accentBg)),
              const SizedBox(width: 10),
              Expanded(child: _ZodiacMini(zodiac: _zodiac, dayOfYear: dayOfYear, accent: widget.accent, accentBg: widget.accentBg)),
            ],
          ),

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('❝', style: TextStyle(fontSize: 36, color: accent.withValues(alpha: 0.15), fontFamily: 'Noto Serif TC', height: 0.6)),
          const SizedBox(height: 10),
          Text('怯？你就輸一世。', textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 6),
          Text('— 嚦咕嚦咕新年財', style: GoogleFonts.notoSansTc(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
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

// ── Personalized Quote ──
class _PersonalizedQuote extends StatelessWidget {
  final String mbti, ennea;
  final Color accent;
  const _PersonalizedQuote({required this.mbti, required this.ennea, required this.accent});

  @override
  Widget build(BuildContext context) {
    final quote = _getQuote(mbti, ennea);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('給 $mbti · $ennea 的你',
            style: GoogleFonts.notoSansTc(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          Text('「$quote」',
            style: GoogleFonts.notoSerifTc(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, height: 1.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('今日嘅 insight 特別為你而寫',
                  style: GoogleFonts.notoSansTc(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
              ),
              // ── Share button ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, size: 18, color: Colors.white),
                  onPressed: () => Share.share('「$quote」\n\n— 型得你 @typingself\n\n⬇️ 了解你嘅 MBTI · Enneagram 人格'),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQuote(String mbti, String ennea) {
    if (mbti.startsWith('E') && ennea.startsWith('4')) return '你嘅情感深度係你最大嘅力量，唔好收埋自己。';
    if (mbti.startsWith('I') && ennea.startsWith('5')) return '你唔需要所有答案先行動，有時試錯都係學習。';
    if (mbti.startsWith('E') && ennea.startsWith('7')) return '你嘅快樂感染力好強，但記住都要照顧自己嘅感受。';
    if (mbti.startsWith('I') && ennea.startsWith('6')) return '你嘅謹慎保護咗你好多次，但唔好俾恐懼限制咗可能性。';
    if (mbti.startsWith('E') && ennea.startsWith('3')) return '你嘅成就有目共睹，但記住你嘅價值唔只係成績。';
    if (mbti.startsWith('I') && ennea.startsWith('4')) return '你嘅獨特唔係缺點，係你嘅 signature。';
    if (mbti.startsWith('E') && ennea.startsWith('2')) return '你成日幫人，今日試吓幫返自己。';
    if (mbti.startsWith('I') && ennea.startsWith('9')) return '你嘅平靜係天賦，但唔好為咗和諧而沉默。';
    return '今日你察覺到啲咩關於自己？每一個 insight 都係成長嘅一步。';
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
