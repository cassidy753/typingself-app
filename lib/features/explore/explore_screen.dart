import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _SectionTitle('已解鎖'),
          _ExploreItem('🧠', 'MBTI九', '重新測試·睇返你嘅報告', '免費 1 次'),
          const SizedBox(height: 12),
          _SectionTitle('免費'),
          _ExploreItem('📊', '心理健康快速檢查', '5 分鐘了解你近況', '免費'),
          const SizedBox(height: 12),
          _SectionTitle('即將推出'),
          _ExploreItem('🔮', '星座深度', '個人星盤·行星解讀', '即將'),
          _ExploreItem('🏛️', '八字基礎', '四柱八字·十神分析', '即將'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.notoSerifTc(
        fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary,
      )),
    );
  }
}

class _ExploreItem extends StatelessWidget {
  final String icon, title, desc, badge;
  const _ExploreItem(this.icon, this.title, this.desc, this.badge);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                Text(desc, style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.cta.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(badge, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.cta)),
          ),
        ],
      ),
    );
  }
}
