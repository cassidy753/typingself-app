// ═══════════════════════════════════════════════════════════════════════
// ZodiacResultScreen — 星座增強結果 Screen
// Shows Sun + Rising + Moon + Combo analysis
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import 'zodiac_calculator.dart';
import 'zodiac_descriptions.dart';

class ZodiacResultScreen extends StatefulWidget {
  final String sunSign;
  final String risingSign;
  final String moonSign;
  final String birthDate;
  final String birthTime;
  final String location;

  const ZodiacResultScreen({
    super.key,
    required this.sunSign,
    required this.risingSign,
    required this.moonSign,
    required this.birthDate,
    required this.birthTime,
    required this.location,
  });

  @override
  State<ZodiacResultScreen> createState() => _ZodiacResultScreenState();
}

class _ZodiacResultScreenState extends State<ZodiacResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final p = await SharedPreferences.getInstance();
    final enRising = ZodiacCalculator.signEn[widget.risingSign] ?? widget.risingSign;
    final enMoon = ZodiacCalculator.signEn[widget.moonSign] ?? widget.moonSign;
    await p.setString('zodiac_rising', enRising.toLowerCase());
    await p.setString('zodiac_moon', enMoon.toLowerCase());
    await p.setBool('zodiac_advanced_done', true);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget;
    final sunEmoji = ZodiacCalculator.signEmoji[r.sunSign] ?? '☀️';
    final risingEmoji = ZodiacCalculator.signEmoji[r.risingSign] ?? '⬆️';
    final moonEmoji = ZodiacCalculator.signEmoji[r.moonSign] ?? '🌙';
    final comboDesc = ZodiacCalculator.getComboDescription(
        r.sunSign, r.risingSign, r.moonSign);
    final risingInfo = ZodiacDescriptions.risingSign[r.risingSign];
    final moonInfo = ZodiacDescriptions.moonSign[r.moonSign];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text('🔮 星座增強版',
                        style: GoogleFonts.notoSerifTc(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple)),
                    const SizedBox(height: 4),
                    Text('${r.birthDate}  ${r.birthTime}  ${r.location}',
                        style: GoogleFonts.notoSansTc(
                            fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 20),

                    // ─── Sun ───
                    _signCard(
                      emoji: sunEmoji,
                      label: '☀️ 太陽星座',
                      sign: r.sunSign,
                      en: ZodiacCalculator.signEn[r.sunSign] ?? '',
                      traits: ZodiacCalculator.signEn.keys.contains(r.sunSign)
                          ? _sunTraits(r.sunSign)
                          : '',
                      color: AppColors.cta,
                    ),
                    const SizedBox(height: 12),

                    // ─── Rising ───
                    _signCard(
                      emoji: risingEmoji,
                      label: '⬆️ 上升星座',
                      sign: r.risingSign,
                      en: ZodiacCalculator.signEn[r.risingSign] ?? '',
                      traits: risingInfo?.appearance ?? '',
                      subText: risingInfo?.summary ?? '',
                      color: AppColors.mustard,
                    ),
                    const SizedBox(height: 12),

                    // ─── Moon ───
                    _signCard(
                      emoji: moonEmoji,
                      label: '🌙 月亮星座',
                      sign: r.moonSign,
                      en: ZodiacCalculator.signEn[r.moonSign] ?? '',
                      traits: moonInfo?.emotionalPattern ?? '',
                      subText: moonInfo?.summary ?? '',
                      color: AppColors.purple,
                    ),
                    const SizedBox(height: 20),

                    // ─── Combo analysis ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                              Text('🎯',
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text('三大星座 Combo',
                                  style: GoogleFonts.notoSansTc(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comboDesc,
                            style: GoogleFonts.notoSansTc(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ─── Rising detail ───
                    if (risingInfo != null)
                      _detailCard(
                        emoji: '⬆️',
                        title: '上升金牛性格',
                        lines: [
                          '外在形象：${risingInfo.appearance}',
                          '第一印象：${risingInfo.firstImpression}',
                          '',
                          risingInfo.summary,
                        ],
                        color: AppColors.mustard,
                      ),
                    const SizedBox(height: 12),

                    // ─── Moon detail ───
                    if (moonInfo != null)
                      _detailCard(
                        emoji: '🌙',
                        title: '月亮巨蟹情感模式',
                        lines: [
                          '情感模式：${moonInfo.emotionalPattern}',
                          '安全感來源：${moonInfo.securitySource}',
                          '',
                          moonInfo.summary,
                        ],
                        color: AppColors.purple,
                      ),

                    const SizedBox(height: 24),

                    // ─── Done button ───
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          textStyle: GoogleFonts.notoSansTc(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          elevation: 0,
                        ),
                        child: const Text('完成'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signCard({
    required String emoji,
    required String label,
    required String sign,
    required String en,
    required String traits,
    required Color color,
    String subText = '',
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.notoSansTc(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
                const SizedBox(height: 2),
                Text(sign,
                    style: GoogleFonts.notoSerifTc(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Text(en,
                    style: GoogleFonts.notoSansTc(
                        fontSize: 11, color: AppColors.textMuted)),
                if (traits.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(traits,
                      style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ],
                if (subText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(subText,
                        style: GoogleFonts.notoSansTc(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required String emoji,
    required String title,
    required List<String> lines,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(title,
                  style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(line,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: line.isEmpty
                          ? Colors.transparent
                          : AppColors.textSecondary,
                      height: 1.5,
                    )),
              )),
        ],
      ),
    );
  }

  String _sunTraits(String sign) {
    const traits = {
      '白羊': '開創·火象·火星',
      '金牛': '固定·土象·金星',
      '雙子': '變動·風象·水星',
      '巨蟹': '開創·水象·月亮',
      '獅子': '固定·火象·太陽',
      '處女': '變動·土象·水星',
      '天秤': '開創·風象·金星',
      '天蠍': '固定·水象·冥王星',
      '人馬': '變動·火象·木星',
      '摩羯': '開創·土象·土星',
      '水瓶': '固定·風象·天王星',
      '雙魚': '變動·水象·海王星',
    };
    return traits[sign] ?? '';
  }
}
