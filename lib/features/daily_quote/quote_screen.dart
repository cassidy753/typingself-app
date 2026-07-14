import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class QuoteScreen extends StatelessWidget {
  final Color accent;
  final Color accentBg;
  const QuoteScreen({super.key, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _Pill('📖 是日金句', accent: accent, accentBg: accentBg),
          const SizedBox(height: 12),
          _QuoteCard(),

          const SizedBox(height: 16),
          _Pill('✨ 屬於你嘅語句', accent: accent, accentBg: accentBg),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('給高級KAM L（ENFJ · 5w4）',
                  style: GoogleFonts.notoSansTc(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 12),
                Text('「今日你察覺到同事有啲唔妥，你嘅直覺係啱嘅。」',
                  style: GoogleFonts.notoSerifTc(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.6)),
                const SizedBox(height: 12),
                Text('今日天蠍座：你嘅直覺特別準',
                  style: GoogleFonts.notoSansTc(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          Text('今日你點？', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: ['😊','😐','😔','😡','😰','😢'].map((e) => Container(
              width: 44, height: 44, margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
            )).toList(),
          ),

          const SizedBox(height: 12),
          _TrendBar(accent: accent),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color accent, accentBg;
  const _Pill(this.text, {required this.accent, required this.accentBg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('❝', style: TextStyle(fontSize: 36, color: AppColors.cta.withValues(alpha: 0.15), fontFamily: 'Noto Serif TC', height: 0.6)),
          const SizedBox(height: 10),
          Text('怯？你就輸一世。', textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 6),
          Text('— 嚦咕嚦咕新年財', style: GoogleFonts.notoSansTc(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  final Color accent;
  const _TrendBar({required this.accent});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [10,16,12,22,26].map((h) => Container(
              width: 5, margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: h > 20 ? accent : AppColors.textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
              height: h.toDouble(),
            )).toList()),
          ),
          const SizedBox(width: 8),
          Text('心情有改善 📈', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
