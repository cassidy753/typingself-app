import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              Text('選擇測驗', style: GoogleFonts.notoSerifTc(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              // 3 test options placeholder
              _testOption(context, 'MBTI 性格測試', '了解你嘅認知偏好'),
              _testOption(context, '九型人格測試', '看清你嘅核心動力'),
              _testOption(context, '全面評估', 'MBTI + 九型人格 完整分析'),
              const Spacer(),
              TextButton(onPressed: () => Navigator.of(context).pushNamed('/home'),
                child: Text('跳過 · 直接進入', style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted))),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _testOption(BuildContext context, String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.notoSerifTc(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(desc, style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    ),
  );
}
