import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'test_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Section 1
              _sectionLabel('— 認識型得你 —'),
              const SizedBox(height: 12),
              Text(
                '型得你係一部通往心靈嘅經典。\n結合 MBTI、九型人格同心理學，\n幫你一步步認識自己。',
                style: GoogleFonts.notoSerifTc(fontSize: 15, height: 1.8, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 40),

              // Section 2
              _sectionLabel('— MBTI × 九型人格 —'),
              const SizedBox(height: 12),
              _infoRow('MBTI', '16型人格，了解你嘅認知偏好'),
              _infoRow('Enneagram', '9型人格，看清你嘅核心動力'),
              const SizedBox(height: 40),

              // Section 3
              _sectionLabel('— 點樣用型得你 —'),
              const SizedBox(height: 12),
              _stepRow('一', '完成測驗，認識你嘅型格'),
              _stepRow('二', '閱讀屬於你嘅經典篇章'),
              _stepRow('三', '每日覺察，記錄你嘅「悟」'),
              _stepRow('四', '隨住成長，型格都會演化'),
              const SizedBox(height: 48),

              // Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TestScreen()),
                  ),
                  child: Text('開始測驗'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
    style: GoogleFonts.notoSansTc(fontSize: 10, letterSpacing: 0.2,
      color: AppColors.gold, fontWeight: FontWeight.w600),
  );

  Widget _infoRow(String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 8, right: 10),
        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textSecondary)),
      ])),
    ]),
  );

  Widget _stepRow(String num, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 28, height: 28, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Center(child: Text(num, style: GoogleFonts.notoSerifTc(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)))),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(desc, style: GoogleFonts.notoSerifTc(fontSize: 14, color: AppColors.textPrimary)),
      )),
    ]),
  );
}
