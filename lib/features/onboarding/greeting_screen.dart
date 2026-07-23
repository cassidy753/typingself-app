import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'intro_screen.dart';

class GreetingScreen extends StatelessWidget {
  const GreetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo mark
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text('型', style: GoogleFonts.notoSerifTc(
                    fontSize: 32, fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  )),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text('型得你',
                style: GoogleFonts.notoSerifTc(
                  fontSize: 32, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text('一部通往心靈嘅經典',
                style: GoogleFonts.notoSerifTc(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 2),
              // Creator message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Text('來自創作人的話',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '認識你自己，是一切智慧嘅開端。\n呢個app，就係幫你行呢條路。',
                      style: GoogleFonts.notoSerifTc(
                        fontSize: 14,
                        height: 1.7,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const IntroScreen()),
                    );
                  },
                  child: const Text('開始旅程'),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
