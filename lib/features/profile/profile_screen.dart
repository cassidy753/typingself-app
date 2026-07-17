// ═══════════════════════════════════════════════════════════════════════
// ProfileScreen — 我嘅 (Tab 3)
// Edition 2 redesign: gradient background, larger fonts, spacious layout
// Daebi palette · HK Cantonese tone
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../integrated_report/integrated_report_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String mbti;
  final String ennea;
  const ProfileScreen({super.key, required this.accent, required this.accentBg, required this.mbti, required this.ennea});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _daysUsed = 0, _quotesSeen = 0, _testsDone = 0;
  bool _shadowDone = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _daysUsed = p.getInt('days_used') ?? 1;
        _quotesSeen = p.getInt('quotes_seen') ?? 1;
        _testsDone = p.getBool('test_done') ?? false ? 1 : 0;
        _shadowDone = p.getBool('shadow_report_viewed') ?? false;
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

    // ── Full-bleed gradient background (lavender → sand → coral) ──
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEBE0F5), // light purple / lavender
            Color(0xFFF5EDE0), // warm sand
            Color(0xFFFCE8E0), // light coral
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── ⭐ Profile Hero Card ──
            _ProfileCard(
              mbti: widget.mbti,
              ennea: widget.ennea,
              accent: widget.accent,
              accentBg: widget.accentBg,
            ),

            const SizedBox(height: 20),

            // ── 📊 使用統計 ──
            _UsageStats(
              daysUsed: _daysUsed,
              quotesSeen: _quotesSeen,
              testsDone: _testsDone,
              shadowDone: _shadowDone,
              accent: widget.accent,
            ),

            const SizedBox(height: 20),

            // ── 📋 完整人格報告 ──
            _SectionHeader('📋 完整人格報告', widget.accent),
            const SizedBox(height: 10),
            _IntegratedReportCTA(
              mbti: widget.mbti,
              ennea: widget.ennea,
              accent: widget.accent,
              accentBg: widget.accentBg,
            ),

            const SizedBox(height: 20),

            // ── 💎 型得你會員 ──
            _SectionHeader('💎 型得你會員', widget.accent),
            const SizedBox(height: 10),
            _MemberCard(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 20),

            // ── 📋 深度報告 ──
            _SectionHeader('📋 深度報告', widget.accent),
            const SizedBox(height: 10),
            _ReportItem('📋', 'MBTI 九型深度分析', '完整認知功能 + 發展建議', '\$18', widget.accent),
            const SizedBox(height: 8),
            _ReportItem('📊', '心靈健康詳細報告', '情景題深度檢測 + 認知模式', '\$18', widget.accent),
            const SizedBox(height: 10),
            Center(
              child: Text('🎁 買任何報告即送 1 個月會員',
                style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textSecondary)),
            ),

            const SizedBox(height: 20),

            // ── ☕ 請我哋飲杯嘢 (Donation) ──
            _SectionHeader('☕ 請我哋飲杯嘢', widget.accent),
            const SizedBox(height: 10),
            _DonationSection(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Profile Hero Card ──
class _ProfileCard extends StatelessWidget {
  final String mbti, ennea;
  final Color accent, accentBg;
  const _ProfileCard({required this.mbti, required this.ennea, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    final name = _getCantoName(mbti);
    final emoji = _getEmoji(mbti);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.85)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Big emoji ──
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 42))),
          ),
          const SizedBox(height: 16),

          // ── Canto name (Noto Serif TC, larger) ──
          Text(name, style: GoogleFonts.notoSerifTc(
            fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white,
            letterSpacing: 1.2,
          )),
          const SizedBox(height: 8),

          // ── MBTI · Enneagram badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$mbti · $ennea', style: GoogleFonts.notoSansTc(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
            )),
          ),

          const SizedBox(height: 20),

          // ── Journey mini-steps ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniStat('了解自己', '第 1 步', Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 24)),
              _miniStat('認識陰影', '第 2 步', Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 24)),
              _miniStat('成長整合', '第 3-4 步', Colors.white.withValues(alpha: 0.9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.notoSansTc(fontSize: 11, color: color.withValues(alpha: 0.7))),
    ]);
  }

  String _getCantoName(String t) {
    switch (t) {
      case 'ENFJ': return '高級KAM L'; case 'INFJ': return '靈性導師'; case 'INTJ': return '戰略家';
      case 'ENTJ': return '指揮官'; case 'ENFP': return '快樂小狗'; case 'INFP': return '夢想家';
      case 'ENTP': return '挑戰者'; case 'INTP': return '思考者'; case 'ESFJ': return '社群心臟';
      case 'ISFJ': return '守護者'; case 'ESTJ': return '執行者'; case 'ISTJ': return '可靠支柱';
      case 'ESFP': return '派對靈魂'; case 'ISFP': return '藝術家'; case 'ESTP': return '冒險家';
      case 'ISTP': return '工匠'; default: return '探索者';
    }
  }

  String _getEmoji(String t) {
    switch (t) {
      case 'ENFJ': return '🌟'; case 'INFJ': return '🌙'; case 'INTJ': return '♟️'; case 'ENTJ': return '👑';
      case 'ENFP': return '🦋'; case 'INFP': return '🌈'; case 'ENTP': return '💡'; case 'INTP': return '🔍';
      case 'ESFJ': return '🤝'; case 'ISFJ': return '🛡️'; case 'ESTJ': return '📋'; case 'ISTJ': return '⚖️';
      case 'ESFP': return '🎉'; case 'ISFP': return '🎨'; case 'ESTP': return '🚀'; case 'ISTP': return '🔧';
      default: return '🧠';
    }
  }
}

// ── Usage Stats ──
class _UsageStats extends StatelessWidget {
  final int daysUsed, quotesSeen, testsDone;
  final bool shadowDone;
  final Color accent;
  const _UsageStats({
    required this.daysUsed,
    required this.quotesSeen,
    required this.testsDone,
    required this.shadowDone,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('$daysUsed', '日使用', accent),
          Container(width: 1, height: 36, color: AppColors.divider.withValues(alpha: 0.4)),
          _statItem('$quotesSeen', '句語句', accent),
          Container(width: 1, height: 36, color: AppColors.divider.withValues(alpha: 0.4)),
          _statItem('${testsDone + (shadowDone ? 1 : 0)}', '已完成', accent),
        ],
      ),
    );
  }

  Widget _statItem(String num, String label, Color accent) {
    return Column(children: [
      Text(num, style: GoogleFonts.notoSerifTc(fontSize: 28, fontWeight: FontWeight.w900, color: accent)),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textMuted)),
    ]);
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  final String text;
  final Color accent;
  const _SectionHeader(this.text, this.accent);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Text(text, style: GoogleFonts.notoSerifTc(
        fontSize: 17, fontWeight: FontWeight.w800, color: accent,
        letterSpacing: 0.5,
      )),
    );
  }
}

// ── Member Card ──
class _MemberCard extends StatelessWidget {
  final Color accent, accentBg;
  const _MemberCard({required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('會員', style: GoogleFonts.notoSansTc(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$15', style: GoogleFonts.notoSerifTc(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(' /次·Stage 3', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _feat('✅ 無限 MBTI + Enneagram 測試'),
          _feat('✅ Shadow Report 完整版'),
          _feat('✅ 成長計劃 + S.O.A.R. 自我觀察日記'),
          _feat('✅ 無廣告'),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showComingSoon(context, 'Stage 3'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.disabled,
                foregroundColor: AppColors.disabledText,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('需要進一步解鎖'),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showComingSoon(context, 'Stage 4'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.disabledText,
                side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              child: const Text('需要進一步解鎖'),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text('所有付款經 Stripe 安全處理 · AlipayHK / FPS / 信用卡',
              style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _feat(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textPrimary)),
    );
  }

  void _showComingSoon(BuildContext context, String stage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$stage 即將開放付款', style: GoogleFonts.notoSansTc(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Report Item ──
class _ReportItem extends StatelessWidget {
  final String icon, title, desc, price;
  final Color accent;
  const _ReportItem(this.icon, this.title, this.desc, this.price, this.accent);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text(desc, style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.disabled.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('需要進一步解鎖', style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.disabledText)),
        ),
      ]),
    );
  }
}

// ── Integrated Report CTA ──
class _IntegratedReportCTA extends StatelessWidget {
  final String mbti, ennea;
  final Color accent, accentBg;
  const _IntegratedReportCTA({
    required this.mbti,
    required this.ennea,
    required this.accent,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.12),
            accentBg.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('📋', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('整合報告', style: GoogleFonts.notoSerifTc(
                      fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 3),
                    Text('一次過睇晒 3 個 Stage 嘅結果', style: GoogleFonts.notoSansTc(
                      fontSize: 12, color: AppColors.textSecondary,
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => IntegratedReportScreen(
                      mbti: mbti,
                      ennea: ennea,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text('睇我嘅完整報告'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: GoogleFonts.notoSansTc(
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _stageBadge('① 型格', AppColors.cta),
              const SizedBox(width: 8),
              _stageBadge('② 暗影', AppColors.purple),
              const SizedBox(width: 8),
              _stageBadge('③ 成長', AppColors.sage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stageBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: GoogleFonts.notoSansTc(
        fontSize: 10, fontWeight: FontWeight.w700, color: color,
      )),
    );
  }
}

// ── Donation Section ──
class _DonationSection extends StatelessWidget {
  final Color accent, accentBg;
  const _DonationSection({required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text('你嘅支持令我哋可以繼續免費提供語句同基本測試 🫶',
            textAlign: TextAlign.center, style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _donateBtn('\$8', context, accent, accentBg),
              const SizedBox(width: 12),
              _donateBtn('\$15', context, accent, accentBg),
              const SizedBox(width: 12),
              _donateBtn('\$30', context, accent, accentBg),
            ],
          ),
          const SizedBox(height: 10),
          Text('一筆過 · 無附加功能 · 純粹支持',
            style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _donateBtn(String amount, BuildContext context, Color accent, Color accentBg) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('多謝你 💜 捐款 $amount 功能即將開放', style: GoogleFonts.notoSansTc(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: accentBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Text(amount, style: GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
      ),
    );
  }
}
