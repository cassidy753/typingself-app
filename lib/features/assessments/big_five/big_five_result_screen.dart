// ═══════════════════════════════════════════════════════════════════════
// BigFiveResultScreen — 大五人格結果 Screen
// Custom radar chart + dimension scores + interpretation + share
// ═══════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import 'big_five_model.dart';
import 'big_five_scorer.dart';

class BigFiveResultScreen extends StatefulWidget {
  final BigFiveResult result;
  final VoidCallback? onComplete;
  const BigFiveResultScreen({
    super.key,
    required this.result,
    this.onComplete,
  });

  @override
  State<BigFiveResultScreen> createState() => _BigFiveResultScreenState();
}

class _BigFiveResultScreenState extends State<BigFiveResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      '🖐️ 大五人格',
                      style: GoogleFonts.notoSerifTc(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cta,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Radar chart ───
                    SizedBox(
                      height: 260,
                      child: CustomPaint(
                        size: const Size(double.infinity, 260),
                        painter: _RadarChartPainter(
                          scores: [
                            r.openness,
                            r.conscientiousness,
                            r.extraversion,
                            r.agreeableness,
                            r.neuroticism,
                          ],
                          labels: ['開放性', '盡責性', '外向性', '親和性', '神經質'],
                          emojis: ['🌍', '🎯', '🗣️', '💛', '🌊'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Score cards ───
                    ..._buildDimensionCards(r),

                    const SizedBox(height: 20),

                    // ─── MBTI suggestion ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('🎯',
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('MBTI 關聯推測',
                                        style: GoogleFonts.notoSansTc(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.purple)),
                                    const SizedBox(height: 2),
                                    Text(
                                        '根據你嘅大五profile推測：${r.suggestedMbtiCorrelation} 傾向',
                                        style: GoogleFonts.notoSansTc(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ─── One-liner ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.mustard.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💬',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '「${r.oneLiner}」',
                              style: GoogleFonts.notoSerifTc(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Done button ───
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          widget.onComplete?.call();
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          textStyle: GoogleFonts.notoSansTc(
                              fontSize: 17, fontWeight: FontWeight.w700),
                          elevation: 0,
                        ),
                        child: const Text('完成'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDimensionCards(BigFiveResult r) {
    final dims = [
      ('開放性', r.openness, r.opennessLabel, r.opennessInterpretation, '🌍'),
      ('盡責性', r.conscientiousness, r.conscientiousnessLabel,
          r.conscientiousnessInterpretation, '🎯'),
      ('外向性', r.extraversion, r.extraversionLabel,
          r.extraversionInterpretation, '🗣️'),
      ('親和性', r.agreeableness, r.agreeablenessLabel,
          r.agreeablenessInterpretation, '💛'),
      ('神經質', r.neuroticism, r.neuroticismLabel,
          r.neuroticismInterpretation, '🌊'),
    ];
    return dims.map((d) {
      final (name, score, label, interp, emoji) = d;
      final pct = BigFiveScorer.formatScore(score);
      final barWidth = (score / 100).clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(name,
                      style: GoogleFonts.notoSansTc(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(pct,
                      style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cta)),
                  const SizedBox(width: 4),
                  Text(label,
                      style: GoogleFonts.notoSansTc(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: barWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _barColor(score),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(interp,
                  style: GoogleFonts.notoSansTc(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _barColor(double score) {
    if (score >= 65) return AppColors.cta;
    if (score >= 35) return AppColors.mustard;
    return AppColors.sage;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Radar chart custom painter (no external dependency)
// ═══════════════════════════════════════════════════════════════════════
class _RadarChartPainter extends CustomPainter {
  final List<double> scores; // 5 values 0–100
  final List<String> labels;
  final List<String> emojis;

  _RadarChartPainter({
    required this.scores,
    required this.labels,
    required this.emojis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 30;
    final n = scores.length;
    final paintGrid = Paint()
      ..color = const Color(0xFFE5DCCE)
      ..strokeWidth = 1;
    final paintData = Paint()
      ..color = const Color(0xFFE0785A).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final paintDataStroke = Paint()
      ..color = const Color(0xFFE0785A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = const Color(0xFFE0785A)
      ..style = PaintingStyle.fill;

    // Grid rings
    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -math.pi / 2 + 2 * math.pi * i / n;
        final x = cx + r * math.cos(angle);
        final y = cy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paintGrid);
    }

    // Axis lines
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(x, y), paintGrid);

      // Labels
      final labelR = radius + 22;
      final lx = cx + labelR * math.cos(angle);
      final ly = cy + labelR * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: '${emojis[i]}\n${labels[i]}',
          style: TextStyle(
            color: const Color(0xFF5C4033),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans TC',
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    // Data polygon
    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final ratio = (scores[i] / 100).clamp(0.0, 1.0);
      final r = radius * ratio;
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, paintData);
    canvas.drawPath(dataPath, paintDataStroke);

    // Data dots
    for (int i = 0; i < n; i++) {
      final ratio = (scores[i] / 100).clamp(0.0, 1.0);
      final r = radius * ratio;
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
