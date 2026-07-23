import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'setup_screen.dart';

class ResultScreen extends StatelessWidget {
  final String mbti;
  final String ennea;
  final String name;
  final String keyMsg;

  const ResultScreen({
    super.key,
    required this.mbti,
    required this.ennea,
    this.name = '',
    this.keyMsg = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Seal stamp
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('鑑', style: GoogleFonts.notoSerifTc(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  )),
                ),
              ),
              const SizedBox(height: 24),
              // Name
              Text(name.isEmpty ? '$mbti · $ennea' : name,
                style: GoogleFonts.notoSerifTc(
                  fontSize: 28, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // MBTI + Ennea
              Text('$mbti · $ennea',
                style: GoogleFonts.notoSerifTc(
                  fontSize: 14,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 20),
              // Key message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  keyMsg.isEmpty ? '認識你自己，是一切智慧嘅開端。' : keyMsg,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 14, height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 2),
              // Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupScreen()),
                  ),
                  child: const Text('設定個人檔案'),
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
