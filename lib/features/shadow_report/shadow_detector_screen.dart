// ═══════════════════════════════════════════════════════════════════════
// ShadowDetectorScreen — Stage 2 free teaser screen
// Users see this after Stage 1 naming celebration
// A mysterious "shadow teaser" prompting them to explore their shadow
// Daebi palette · HK Cantonese tone
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../personality_naming/naming_engine.dart';
import 'shadow_report_engine.dart';
import 'shadow_report_screen.dart';

class ShadowDetectorScreen extends StatefulWidget {
  final String mbti;
  final String ennea;
  final VoidCallback onSkip;

  const ShadowDetectorScreen({
    super.key,
    required this.mbti,
    required this.ennea,
    required this.onSkip,
  });

  @override
  State<ShadowDetectorScreen> createState() => _ShadowDetectorScreenState();
}

class _ShadowDetectorScreenState extends State<ShadowDetectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = NamingEngine.getName(widget.mbti, widget.ennea);
    final typeLabel = '${widget.mbti} · ${widget.ennea}';
    final personaName = name?.nameCanto ?? '探索者';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ─── Mysterious shadow icon with pulse ───
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purple.withValues(alpha: 0.2),
                          AppColors.cta.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎭', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ─── Title ───
                Text(
                  '你睇到自己嘅 Shadow 未？',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.03),

                const SizedBox(height: 16),

                // ─── Subtitle ───
                Text(
                  '表面上你係「$personaName」——但你有冇諗過你收埋咗咩？',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // ─── Type badge ───
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    typeLabel,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.purple,
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                // ─── Teaser description ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _teaserRow('🎭', '你嘅面具', '你俾人見到嘅樣'),
                      const Divider(height: 20, color: AppColors.divider),
                      _teaserRow('🌑', '你嘅陰影', '你收埋咗嗰一面'),
                      const Divider(height: 20, color: AppColors.divider),
                      _teaserRow('🛡️', '防禦機制', '唔覺意用緊嘅保護'),
                      const Divider(height: 20, color: AppColors.divider),
                      _teaserRow('🧠', '壓抑嘅功能', '成日忽略嘅認知muscle'),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 36),

                // ─── Reveal CTA ───
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _revealShadow,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: GoogleFonts.notoSansTc(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔮 睇我嘅 Shadow'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 12),

                // ─── Skip ───
                TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    '下次先睇',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _teaserRow(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: GoogleFonts.notoSansTc(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                style: GoogleFonts.notoSansTc(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _revealShadow() {
    final engine = ShadowReportEngine();
    final report = engine.generate(widget.mbti, widget.ennea);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShadowReportScreen(
          report: report,
          onComplete: widget.onSkip,
        ),
      ),
    );
  }
}
