import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../mood_checkin/mood_screen.dart';

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Part A: General Quote
          _Pill('🎬 電影金句'),
          const SizedBox(height: 12),
          _QuoteCard(
            quote: '怯？你就輸一世。',
            source: '— 嚦咕嚦咕新年財',
          ),

          const SizedBox(height: 16),
          // Part B: Personalized Quote
          _Pill('✨ 屬於你嘅語句', coral: true),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B3A5C), Color(0xFF2A5A8C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('給高級KAM L（ENFJ · 5w4）',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 12),
                Text(
                  '「今日你察覺到同事有啲唔妥，你嘅直覺係啱嘅。一句問候可能改變佢成日。」',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: Colors.white, height: 1.6),
                ),
                const SizedBox(height: 12),
                Text('今日天蠍座：你嘅直覺特別準，信自己一次',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.6),
                  )),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Inline Mood
          _MoodSection(),

          const SizedBox(height: 20),
          // Trend
          _TrendBar(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool coral;
  const _Pill(this.text, {this.coral = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: coral
          ? AppColors.cta.withValues(alpha: 0.12)
          : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: coral ? AppColors.cta : AppColors.primary,
      )),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  final String source;
  const _QuoteCard({required this.quote, required this.source});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 20, offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        children: [
          Text('❝', style: TextStyle(
            fontSize: 48, color: AppColors.cta.withValues(alpha: 0.2),
            fontFamily: 'Noto Serif TC', height: 0.6,
          )),
          const SizedBox(height: 12),
          Text(quote,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: AppColors.primary, height: 1.6,
            )),
          const SizedBox(height: 8),
          Text(source,
            style: GoogleFonts.notoSansTc(
              fontSize: 13, fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            )),
        ],
      ),
    );
  }
}

class _MoodSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('今日你點？',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: ['😊','😐','😔','😡','😰','😢'].map((e) {
            return Container(
              width: 44, height: 44,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TrendBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Simple sparkline bars
          SizedBox(
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [10, 16, 12, 22, 26, 20, 24].map((h) {
                return Container(
                  width: 6, margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  height: h.toDouble(),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          Text('呢個星期心情有改善 📈',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
