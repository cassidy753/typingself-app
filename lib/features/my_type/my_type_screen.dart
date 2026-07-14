import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class MyTypeScreen extends StatelessWidget {
  final Color accent;
  final Color accentBg;
  const MyTypeScreen({super.key, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                child: const Center(child: Text('🧠', style: TextStyle(fontSize: 38))),
              ),
              const SizedBox(height: 10),
              Text('高級KAM L', style: GoogleFonts.notoSerifTc(fontSize: 32, fontWeight: FontWeight.w900, color: accent)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(20)),
                child: Text('ENFJ · 5w4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Text('「你睇到人哋睇唔到嘅 pattern」', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(18)),
              child: const Center(child: Text('📤 Share', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
            )),
            const SizedBox(width: 8),
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(18)),
              child: const Center(child: Text('✏️ 轉 tagline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            )),
          ]),
          const SizedBox(height: 20),
          Text('朋友嘅型', style: GoogleFonts.notoSerifTc(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(height: 10),
          _friendRow('🎯', '行動先鋒', 'ESTP · 7w8'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surface,
            ),
            child: const Center(child: Text('+ 邀請朋友', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _friendRow(String emoji, String name, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(type, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
        const Text('+', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
      ]),
    );
  }
}
