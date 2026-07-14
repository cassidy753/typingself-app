import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class SupportScreen extends StatelessWidget {
  final Color accent;
  final Color accentBg;
  const SupportScreen({super.key, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _stat('23', '日使用', accent, accentBg),
            const SizedBox(width: 24),
            _stat('21', '句語句', accent, accentBg),
            const SizedBox(width: 24),
            _stat('3', '個測試', accent, accentBg),
          ]),
          const SizedBox(height: 12),
          Text('多謝你用咗型得你咁耐 🫶\n如果你想支持我哋繼續做落去…',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 16),
          _memberCard(accent, accentBg),
          const SizedBox(height: 20),
          Text('深度報告', style: GoogleFonts.notoSerifTc(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(height: 10),
          _reportItem('📋', 'MBTI九 深度分析', '完整認知功能 + 發展建議', '\$18', accent),
          const SizedBox(height: 6),
          _reportItem('📊', '心靈健康詳細報告', '情景題深度檢測 + 認知模式', '\$18', accent),
          const SizedBox(height: 6),
          Center(child: Text('🎁 買任何報告即送 1 個月會員', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
          const SizedBox(height: 20),
          Center(child: Text('或者請我哋飲杯嘢 ☕', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _donateBtn('\$8', accent, accentBg),
            const SizedBox(width: 8),
            _donateBtn('\$15', accent, accentBg),
            const SizedBox(width: 8),
            _donateBtn('\$30', accent, accentBg),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _stat(String num, String label, Color accent, Color accentBg) {
    return Column(children: [
      Text(num, style: GoogleFonts.notoSerifTc(fontSize: 26, fontWeight: FontWeight.w900, color: accent)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
    ]);
  }

  Widget _memberCard(Color accent, Color accentBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('會員', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$8', style: GoogleFonts.notoSerifTc(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const Padding(padding: EdgeInsets.only(bottom: 4), child: Text(' /月', style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          ]),
        ]),
        const SizedBox(height: 10),
        _feat('✅ 無限 MBTI九 測試'),
        _feat('✅ 無廣告'),
        const SizedBox(height: 14),
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(24)),
          child: const Center(child: Text('即時加入', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        const SizedBox(height: 6),
        Center(child: Text('或 HK\$80/年（～\$6.7/月）', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
      ]),
    );
  }

  Widget _feat(String text) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)));
  }

  Widget _reportItem(String icon, String title, String desc, String price, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
      ]),
    );
  }

  Widget _donateBtn(String amount, Color accent, Color accentBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
    );
  }
}
