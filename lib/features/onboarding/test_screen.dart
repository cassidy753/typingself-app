import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/decision_tree_engine.dart';

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
              const SizedBox(height: 8),
              Text('揀一款開始認識自己', style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              _testOption(context, '快測 · 12 題', 'MBTI 快速辨識', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AssessmentIntroScreen(
                  engine: DecisionTreeEngine(),
                  onComplete: (mbti, ennea) => _onTestDone(context, mbti, ennea),
                )));
              }),
              _testOption(context, '標準 · 20 題', 'MBTI + 九型初步', () {}),
              _testOption(context, '深度 · 45 題', 'MBTI + 九型完整分析', () {}),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
                child: Text('跳過 · 直接進入', style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _testOption(BuildContext context, String title, String desc, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.notoSerifTc(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(desc, style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textSecondary)),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }

  void _onTestDone(BuildContext context, String mbti, String ennea) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
