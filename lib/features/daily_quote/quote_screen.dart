import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _daysUsed = 0;
  int _quotesSeen = 0;
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
      _daysUsed = prefs.getInt('days_used') ?? 1;
      _quotesSeen = prefs.getInt('quotes_seen') ?? 1;
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
          _GreetingHeader(accent: widget.accent, accentBg: widget.accentBg, mbti: widget.mbti, ennea: widget.ennea),

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

          // ── Quick Stats ──
          Row(
            children: [
              _StatCard('📅', '$_daysUsed 日', '使用型得你', widget.accent),
              const SizedBox(width: 8),
              _StatCard('💬', '$_quotesSeen 句', '已讀語句', widget.accent),
              const SizedBox(width: 8),
              _StatCard('🧠', '${widget.mbti}', '人格類型', widget.accent),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Greeting ──
class _GreetingHeader extends StatelessWidget {
  final Color accent, accentBg;
  final String mbti, ennea;
  const _GreetingHeader({required this.accent, required this.accentBg, required this.mbti, required this.ennea});

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
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(_getEmoji(mbti), style: const TextStyle(fontSize: 24)),
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
                Text('$mbti · $ennea  — 今日都係了解自己嘅一日',
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

  String _getEmoji(String mbti) {
    switch (mbti) {
      case 'ENFJ': return '🌟';
      case 'INFJ': return '🌙';
      case 'INTJ': return '♟️';
      case 'ENTJ': return '👑';
      case 'ENFP': return '🦋';
      case 'INFP': return '🌈';
      case 'ENTP': return '💡';
      case 'INTP': return '🔍';
      case 'ESFJ': return '🤝';
      case 'ISFJ': return '🛡️';
      case 'ESTJ': return '📋';
      case 'ISTJ': return '⚖️';
      case 'ESFP': return '🎉';
      case 'ISFP': return '🎨';
      case 'ESTP': return '🚀';
      case 'ISTP': return '🔧';
      default: return '🧠';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Icon(
              i < 4 ? Icons.star : Icons.star_border,
              size: 14,
              color: accent.withValues(alpha: 0.6),
            )),
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
          Text('今日嘅 insight 特別為你而寫',
            style: GoogleFonts.notoSansTc(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
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
    final moods = ['😊','😐','😔','😡','😰'];
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
          const SizedBox(height: 10),
          Text('今日你點？', style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(moods.length, (i) => GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _selected == i ? widget.accentBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _selected == i ? Border.all(color: widget.accent.withValues(alpha: 0.3)) : null,
                ),
                child: Center(child: Text(moods[i], style: const TextStyle(fontSize: 20))),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text(_selected != null ? _moodLabel(_selected!) : '㩒一下記錄今日心情',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _moodLabel(int i) {
    final labels = ['好好', '普通', '唔好', '好炆', '好擔心'];
    return '今日心情：${labels[i]}';
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

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String emoji, stat, label;
  final Color accent;
  const _StatCard(this.emoji, this.stat, this.label, this.accent);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(stat, style: GoogleFonts.notoSerifTc(fontSize: 16, fontWeight: FontWeight.w900, color: accent)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
