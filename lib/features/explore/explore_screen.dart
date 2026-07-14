import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ExploreScreen extends StatelessWidget {
  final Color accent;
  final Color accentBg;
  const ExploreScreen({super.key, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _SectionTitle('已解鎖', accent: accent),
          _ExploreItem('🧠', 'MBTI九 測試', '重新了解你嘅人格組合', '免費 1 次', accent, accentBg),
          const SizedBox(height: 12),
          _SectionTitle('免費', accent: accent),
          _ExploreItem('📊', '心靈健康檢查', '5 分鐘了解你近況', '免費', accent, accentBg),
          const SizedBox(height: 12),
          _SectionTitle('即將推出', accent: accent),
          _ExploreItem('🔮', '星座深度', '個人星盤·行星解讀', '即將', accent, accentBg),
          _ExploreItem('🏛️', '八字基礎', '四柱八字·十神分析', '即將', accent, accentBg),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text; final Color accent;
  const _SectionTitle(this.text, {required this.accent});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.notoSerifTc(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
    );
  }
}

class _ExploreItem extends StatelessWidget {
  final String icon, title, desc, badge;
  final Color accent, accentBg;
  const _ExploreItem(this.icon, this.title, this.desc, this.badge, this.accent, this.accentBg);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(10)),
            child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
          ),
        ],
      ),
    );
  }
}
