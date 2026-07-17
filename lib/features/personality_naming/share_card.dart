/// Shareable Result Card — a beautiful card showing MBTI + Enneagram results
/// that can be shared as text. Includes a unique link to the user's results.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';

/// MBTI personality display names (same as profile_screen).
String _getCantoName(String mbti) {
  switch (mbti) {
    case 'ENFJ': return '高級KAM L'; case 'INFJ': return '靈性導師';
    case 'INTJ': return '戰略家'; case 'ENTJ': return '指揮官';
    case 'ENFP': return '快樂小狗'; case 'INFP': return '夢想家';
    case 'ENTP': return '挑戰者'; case 'INTP': return '思考者';
    case 'ESFJ': return '社群心臟'; case 'ISFJ': return '守護者';
    case 'ESTJ': return '執行者'; case 'ISTJ': return '可靠支柱';
    case 'ESFP': return '派對靈魂'; case 'ISFP': return '藝術家';
    case 'ESTP': return '冒險家'; case 'ISTP': return '工匠';
    default: return '探索者';
  }
}

String _getEmoji(String mbti) {
  switch (mbti) {
    case 'ENFJ': return '🌟'; case 'INFJ': return '🌙'; case 'INTJ': return '♟️';
    case 'ENTJ': return '👑'; case 'ENFP': return '🦋'; case 'INFP': return '🌈';
    case 'ENTP': return '💡'; case 'INTP': return '🔍'; case 'ESFJ': return '🤝';
    case 'ISFJ': return '🛡️'; case 'ESTJ': return '📋'; case 'ISTJ': return '⚖️';
    case 'ESFP': return '🎉'; case 'ISFP': return '🎨'; case 'ESTP': return '🚀';
    case 'ISTP': return '🔧'; default: return '🧠';
  }
}

/// Generate a unique shareable link for a user's results.
/// Uses MBTI + Enneagram + a timestamp seed as simple unique ID.
String generateShareLink(String mbti, String ennea) {
  // Simple unique ID: first 6 chars of base64-encoded mbti+ennea+timestamp
  final raw = '$mbti-$ennea-${DateTime.now().millisecondsSinceEpoch}';
  final code = raw.hashCode.toRadixString(36).padLeft(6, '0').substring(0, 6);
  return 'https://xingdeni.app/r/$code';
}

/// Share the result card as a formatted text message.
Future<void> shareResultCard(String mbti, String ennea, {bool includeLink = true}) async {
  final name = _getCantoName(mbti);
  final emoji = _getEmoji(mbti);
  final link = includeLink ? generateShareLink(mbti, ennea) : 'https://xingdeni.app';

  final text = [
    '🧠 我嘅人格結果',
    '',
    '$emoji $name',
    '$mbti · $ennea',
    '',
    '「型得你」— 認識自己嘅第一步',
    '一步一步由人格到整合 🌱',
    '',
    link,
  ].join('\n');

  await Share.share(text, subject: '我嘅人格結果 — 型得你');
}

/// The actual shareable card widget (for in-app display).
class ShareResultCard extends StatelessWidget {
  final String mbti;
  final String ennea;
  final Color accent;

  const ShareResultCard({
    super.key,
    required this.mbti,
    required this.ennea,
    this.accent = AppColors.cta,
  });

  @override
  Widget build(BuildContext context) {
    final name = _getCantoName(mbti);
    final emoji = _getEmoji(mbti);
    final link = generateShareLink(mbti, ennea);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Emoji ──
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          // ── Name ──
          Text(
            name,
            style: GoogleFonts.notoSerifTc(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // ── MBTI + Enneagram ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$mbti · $ennea',
              style: GoogleFonts.notoSansTc(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Share button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => shareResultCard(mbti, ennea),
              icon: const Icon(Icons.share, size: 18),
              label: Text(
                '分享我嘅結果',
                style: GoogleFonts.notoSansTc(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
            ),
          ),
          // ── Link ──
          const SizedBox(height: 10),
          Text(
            link,
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
