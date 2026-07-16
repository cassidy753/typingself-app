// ═══════════════════════════════════════════════════════════════════════
// TypeSoulScreen — Full personality profile display for MBTI × Enneagram
// Shows: name, core description, superpowers, blindspots, shadow,
//        growth path, daily quote, and roast mode
// Daebi Earthy palette · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../personality_naming/naming_engine.dart';
import 'typesoul.dart';
import 'typesoul_engine.dart';

class TypeSoulScreen extends StatefulWidget {
  final String mbti;
  final String ennea;
  final VoidCallback onContinue;

  const TypeSoulScreen({
    super.key,
    required this.mbti,
    required this.ennea,
    required this.onContinue,
  });

  @override
  State<TypeSoulScreen> createState() => _TypeSoulScreenState();
}

class _TypeSoulScreenState extends State<TypeSoulScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  TypeSoul? _typeSoul;
  PersonalityName? _name;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _typeSoul = TypeSoulEngine.lookUp(widget.mbti, widget.ennea);
    _name = NamingEngine.getName(widget.mbti, widget.ennea);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            _buildHeader(),
            // ─── Scrollable Content ───
            Expanded(
              child: _typeSoul != null
                  ? _buildProfile(_typeSoul!)
                  : _buildFallback(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final emoji = _typeSoul?.emoji ?? _name?.emoji ?? '🧠';
    final name = _typeSoul?.nameCanto ?? _name?.nameCanto ?? '探索者';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onContinue,
                child: Icon(Icons.arrow_back_rounded,
                    color: AppColors.textSecondary, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.cta.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '型格 · $name',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.mbti} · ${widget.ennea}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(TypeSoul ts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Hero Emoji ───
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.cta.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(ts.emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
          ).animate(controller: _animCtrl)
            .scaleXY(begin: 0, end: 1, duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),

          // ─── Core Description ───
          _section(
            '📖 核心描述',
            Text(
              ts.coreDescription.replaceAll('\\n', '\n'),
              style: GoogleFonts.notoSansTc(
                fontSize: 14,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            delay: 100,
          ),
          const SizedBox(height: 20),

          // ─── Superpowers ───
          _section(
            '🎯 超能力',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ts.superpowers.map((sp) => _bulletItem(sp, AppColors.sage)).toList(),
            ),
            delay: 200,
          ),
          const SizedBox(height: 20),

          // ─── Blindspots ───
          _section(
            '⚠️ 盲點',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ts.blindspots.map((bp) => _bulletItem(bp, AppColors.cta)).toList(),
            ),
            delay: 300,
          ),
          const SizedBox(height: 20),

          // ─── Shadow ───
          _section(
            '🌑 壓力下既佢',
            Text(
              ts.shadowDescription.replaceAll('\\n', '\n'),
              style: GoogleFonts.notoSansTc(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
            delay: 400,
          ),
          const SizedBox(height: 20),

          // ─── Growth Path ───
          _section(
            '📈 成長路徑',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ts.growthPath.asMap().entries.map((e) =>
                _numberedItem(e.key + 1, e.value)
              ).toList(),
            ),
            delay: 500,
          ),
          const SizedBox(height: 20),

          // ─── Daily Quote ───
          if (ts.dailyQuote.isNotEmpty)
            _section(
              '💬 每日一句',
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Text(
                  ts.dailyQuote
                      .replaceAll('\\n', '\n')
                      .replaceAll('> ', ''),
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 15,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
              ),
              delay: 600,
            ),
          const SizedBox(height: 20),

          // ─── Roast Mode ───
          if (ts.roastMode.isNotEmpty)
            _section(
              '😂 寸嘴mode',
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mustard.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mustard.withValues(alpha: 0.2)),
                ),
                child: Text(
                  ts.roastMode.replaceAll('\\n', '\n'),
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              delay: 700,
            ),
          const SizedBox(height: 32),

          // ─── Continue Button ───
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: widget.onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: GoogleFonts.notoSansTc(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('🔮 探索我嘅 Shadow'),
            ),
          ).animate(controller: _animCtrl)
            .fadeIn(duration: 400.ms, delay: 800.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 800.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🧠', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '型格資料準備中',
              style: GoogleFonts.notoSerifTc(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '你嘅專屬 TypeSoul profile 將會喺之後更新加入',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTc(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: widget.onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text('繼續'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget content, {int delay = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSerifTc(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate(controller: _animCtrl)
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay))
          .slideX(begin: -0.02, duration: 300.ms, delay: Duration(milliseconds: delay)),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _bulletItem(String text, Color accent) {
    // Clean markdown bold markers
    final clean = text.replaceAll('**', '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clean,
              style: GoogleFonts.notoSansTc(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberedItem(int num, String text) {
    final clean = text.replaceAll('**', '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$num',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clean,
              style: GoogleFonts.notoSansTc(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
