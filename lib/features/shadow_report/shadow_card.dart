// ═══════════════════════════════════════════════════════════════════════
// ShadowCard — Shareable card for Shadow Report
// Shows persona ↔ shadow in a clean shareable format
// Integrates NamingEngine for the personality name
// Daebi palette · HK Cantonese tone
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'shadow_report_engine.dart';

class ShadowCard {
  /// Generate and share a Shadow Card image/caption
  static void share(BuildContext context, ShadowReport report) {
    final name = report.personalityName;
    final typeLabel = '${report.mbtiType} · ${report.enneagramType}';
    final personaName = report.persona.name;
    final shadowName = report.shadowPattern.name;
    final maskPhrase = report.persona.maskPhrase;

    final caption = '''
🎭 我嘅 Shadow Report

🔮 $typeLabel
${name != null ? '🏷️ ${name.nameCanto}' : ''}

─── 戴緊嘅面具 ───
$personaName
$maskPhrase

─── 收埋咗嘅陰影 ───
$shadowName
「${report.shadowPattern.description.split('。').first}」

了解自己，贏返自己
@typingself
''';

    Share.share(
      caption.trim(),
      subject: '🎭 我嘅 Shadow Report — @typingself',
    );
  }

  /// Build a card widget for screenshot/preview
  static Widget buildCard(BuildContext context, ShadowReport report) {
    final name = report.personalityName;
    final typeLabel = '${report.mbtiType} · ${report.enneagramType}';

    return Container(
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.85),
            AppColors.cta.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            '我嘅Shadow',
            style: GoogleFonts.notoSerifTc(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              typeLabel,
              style: GoogleFonts.notoSansTc(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
          if (name != null) ...[
            const SizedBox(height: 6),
            Text(
              name.nameCanto,
              style: GoogleFonts.notoSansTc(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Persona
          _cardLine('戴緊嘅面具', report.persona.name, report.persona.maskPhrase),
          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),

          // Shadow
          _cardLine('收埋咗嘅陰影', report.shadowPattern.name,
              report.shadowPattern.description.split('。').first + '。'),

          const SizedBox(height: 24),

          // Tagline
          Text(
            '「了解自己，贏返自己」',
            style: GoogleFonts.notoSerifTc(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@typingself',
            style: GoogleFonts.notoSansTc(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _cardLine(String label, String name, String phrase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '─── $label ───',
          style: GoogleFonts.notoSansTc(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.notoSerifTc(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phrase,
          style: GoogleFonts.notoSansTc(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
