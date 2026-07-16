import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../daily_quote/zodiac_service.dart';

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
  bool _loaded = false;
  bool _consented = false;
  String? _zodiac;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _consented = prefs.getBool('consent_given') ?? false;
      _zodiac = prefs.getString('zodiac_sign');
      _loaded = true;
    });
  }

  Future<void> _setZodiac(String sign) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zodiac_sign', sign);
    setState(() => _zodiac = sign);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── ⭐ Profile Card ──
          _ProfileCard(
            mbti: widget.mbti,
            ennea: widget.ennea,
            accent: widget.accent,
            accentBg: widget.accentBg,
          ),

          const SizedBox(height: 14),

          // ── 📊 使用統計 ──
          _UsageStats(accent: widget.accent, accentBg: widget.accentBg),

          const SizedBox(height: 14),

          // ── 💎 會員 ──
          _SectionHeader('💎 型得你會員', widget.accent),
          const SizedBox(height: 8),
          _MemberCard(accent: widget.accent, accentBg: widget.accentBg),

          const SizedBox(height: 14),

          // ── 📋 深度報告 ──
          _SectionHeader('📋 深度報告', widget.accent),
          const SizedBox(height: 8),
          _ReportItem('📋', 'MBTI九 深度分析', '完整認知功能 + 發展建議', '\$18', widget.accent),
          const SizedBox(height: 6),
          _ReportItem('📊', '心靈健康詳細報告', '情景題深度檢測 + 認知模式', '\$18', widget.accent),
          const SizedBox(height: 6),
          Center(
            child: Text('🎁 買任何報告即送 1 個月會員',
              style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textSecondary)),
          ),

          const SizedBox(height: 14),

          // ── ☕ 支持我哋 (Donation) ──
          _SectionHeader('☕ 請我哋飲杯嘢', widget.accent),
          const SizedBox(height: 8),
          _DonationSection(accent: widget.accent, accentBg: widget.accentBg),

          const SizedBox(height: 14),

          // ── ⚙️ 設定 ──
          _SectionHeader('⚙️ 設定', widget.accent),
          const SizedBox(height: 8),
          _SettingsSection(
            consented: _consented,
            zodiac: _zodiac,
            onConsentChanged: () => _showConsentDialog(),
            onZodiacChanged: _setZodiac,
            accent: widget.accent,
            accentBg: widget.accentBg,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showConsentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('資料使用同意', style: GoogleFonts.notoSansTc(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text('我哋會用你嘅資料嚟提供個人化語句同分析。你嘅資料唔會分享俾第三方。',
          style: GoogleFonts.notoSansTc(fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              SharedPreferences.getInstance().then((p) => p.setBool('consent_given', true));
              setState(() => _consented = true);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('同意'),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ──
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.85)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 12),
          Text(name, style: GoogleFonts.notoSerifTc(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('$mbti · $ennea', style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat('了解自己', '第 1 步', Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 20)),
              _MiniStat('認識陰影', '第 2 步', Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 20)),
              _MiniStat('成長整合', '第 3-4 步', Colors.white.withValues(alpha: 0.9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _MiniStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.notoSansTc(fontSize: 9, color: color.withValues(alpha: 0.7))),
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
class _UsageStats extends StatefulWidget {
  final Color accent, accentBg;
  const _UsageStats({required this.accent, required this.accentBg});
  @override
  State<_UsageStats> createState() => _UsageStatsState();
}

class _UsageStatsState extends State<_UsageStats> {
  int _daysUsed = 0, _quotesSeen = 0, _testsDone = 0;
  bool _shadowDone = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() {
        _daysUsed = p.getInt('days_used') ?? 1;
        _quotesSeen = p.getInt('quotes_seen') ?? 1;
        _testsDone = p.getBool('test_done') ?? false ? 1 : 0;
        _shadowDone = p.getBool('shadow_report_viewed') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem('$_daysUsed', '日使用', widget.accent),
          _StatItem('$_quotesSeen', '句語句', widget.accent),
          _StatItem('${_testsDone + (_shadowDone ? 1 : 0)}', '已完成', widget.accent),
        ],
      ),
    );
  }

  Widget _StatItem(String num, String label, Color accent) {
    return Column(children: [
      Text(num, style: GoogleFonts.notoSerifTc(fontSize: 24, fontWeight: FontWeight.w900, color: accent)),
      Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
      child: Text(text, style: GoogleFonts.notoSerifTc(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('會員', style: GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$15', style: GoogleFonts.notoSerifTc(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(' /次·Stage 3', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          _Feat('✅ 無限 MBTI + Enneagram 測試'),
          _Feat('✅ Shadow Report 完整版'),
          _Feat('✅ 成長計劃 + S.O.A.R. 自我觀察日記'),
          _Feat('✅ 無廣告'),
          const SizedBox(height: 14),

          // Stage 3 button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showComingSoon(context, 'Stage 3'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0785A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: const Text('解鎖 Stage 3 — \$15'),
            ),
          ),
          const SizedBox(height: 6),

          // Stage 4 / Monthly
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showComingSoon(context, 'Stage 4'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9B72AA),
                side: BorderSide(color: const Color(0xFF9B72AA).withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('Stage 4 月費 — \$28/月 或 \$168/年'),
            ),
          ),

          const SizedBox(height: 6),
          Center(
            child: Text('所有付款經 Stripe 安全處理 · AlipayHK / FPS / 信用卡',
              style: GoogleFonts.notoSansTc(fontSize: 10, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _Feat(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(text, style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textPrimary)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(desc, style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Text(price, style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
      ]),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('你嘅支持令我哋可以繼續免費提供語句同基本測試 🫶',
            textAlign: TextAlign.center, style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DonateBtn('\$8', context, accent, accentBg),
              const SizedBox(width: 8),
              _DonateBtn('\$15', context, accent, accentBg),
              const SizedBox(width: 8),
              _DonateBtn('\$30', context, accent, accentBg),
            ],
          ),
          const SizedBox(height: 8),
          Text('一筆過 · 無附加功能 · 純粹支持',
            style: GoogleFonts.notoSansTc(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _DonateBtn(String amount, BuildContext context, Color accent, Color accentBg) {
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: accentBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Text(amount, style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
      ),
    );
  }
}

// ── Settings Section ──
class _SettingsSection extends StatelessWidget {
  final bool consented;
  final String? zodiac;
  final VoidCallback onConsentChanged;
  final ValueChanged<String> onZodiacChanged;
  final Color accent, accentBg;
  const _SettingsSection({
    required this.consented,
    required this.zodiac,
    required this.onConsentChanged,
    required this.onZodiacChanged,
    required this.accent,
    required this.accentBg,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zodiac setting
          Text('我嘅星座', style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: zodiac,
              isExpanded: true,
              hint: Text('揀你嘅太陽星座…', style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textMuted)),
              items: ZodiacService.signs.map((s) => DropdownMenuItem(
                value: s,
                child: Text('${ZodiacService.signEmoji[s] ?? ''} $s',
                  style: GoogleFonts.notoSansTc(fontSize: 14)),
              )).toList(),
              onChanged: (v) { if (v != null) onZodiacChanged(v); },
            ),
          ),
          if (zodiac != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('${ZodiacService.signEmoji[zodiac]} ', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$zodiac · ${ZodiacService.signTraits[zodiac]?['element'] ?? ''}象',
                          style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
                        Text('守護星：${ZodiacService.signTraits[zodiac]?['planet'] ?? ''}',
                          style: GoogleFonts.notoSansTc(fontSize: 12, color: accent.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 24),

          // Consent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('資料使用同意', style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('用於個人化語句同分析', style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              Switch(
                value: consented,
                onChanged: (_) => onConsentChanged(),
                activeColor: accent,
              ),
            ],
          ),

          const Divider(height: 16),

          _SettingsItem(Icons.download_outlined, '下載我的資料', () {}),
          const SizedBox(height: 4),
          _SettingsItem(Icons.delete_outline, '刪除帳戶', () {}, color: Colors.redAccent),
          const SizedBox(height: 4),
          _SettingsItem(Icons.description_outlined, '私隱政策', () {}),
          const SizedBox(height: 4),
          _SettingsItem(Icons.info_outline, '版本 1.0.0', () {}),
        ],
      ),
    );
  }

  Widget _SettingsItem(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: GoogleFonts.notoSansTc(fontSize: 13, color: color ?? AppColors.textPrimary)),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
