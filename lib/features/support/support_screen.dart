import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Usage stats
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stat('23', '日使用'),
              const SizedBox(width: 32),
              _Stat('21', '句語句'),
              const SizedBox(width: 32),
              _Stat('3', '個測試'),
            ],
          ),
          const SizedBox(height: 12),
          Text('多謝你用咗型得你咁耐。\n如果你想支持我哋繼續做落去…',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 20),

          // Membership card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('會員', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$8', style: GoogleFonts.notoSerifTc(
                          fontSize: 36, fontWeight: FontWeight.w900,
                          color: AppColors.primary)),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(' /月', style: TextStyle(
                            fontSize: 14, color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Feature('無限 MBTI九 測試'),
                _Feature('無廣告'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('即時加入', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                const SizedBox(height: 8),
                const Center(child: Text('或 HK\$80/年（～\$6.7/月）',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reports
          Text('深度報告', style: GoogleFonts.notoSerifTc(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 10),
          _ReportItem('📋', 'MBTI九 深度分析報告', '完整認知功能 + 發展建議', '\$18'),
          const SizedBox(height: 8),
          _ReportItem('📊', '心理健康詳細報告', '情景題深度檢測 + 認知模式', '\$18'),
          const SizedBox(height: 8),
          const Center(child: Text('🎁 買任何報告即送 1 個月會員',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted))),

          const SizedBox(height: 20),
          // Donation
          const Center(child: Text('或者請我哋飲杯嘢 ☕',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DonateBtn('\$8'),
              const SizedBox(width: 8),
              _DonateBtn('\$15'),
              const SizedBox(width: 8),
              _DonateBtn('\$30'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _Stat(String num, String label) {
    return Column(
      children: [
        Text(num, style: GoogleFonts.notoSerifTc(
          fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.secondary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _Feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _ReportItem(String icon, String title, String desc, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _DonateBtn(String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(amount, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}
