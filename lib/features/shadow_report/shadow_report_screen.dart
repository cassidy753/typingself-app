// ═══════════════════════════════════════════════════════════════════════
// ShadowReportScreen — 4 swipeable pages: Persona → Shadow → Defense → Repressed
// Integrates NamingEngine (289 entries) for the personality name
// Daebi palette · HK Cantonese tone
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../personality_naming/naming_engine.dart';
import 'shadow_report_engine.dart';

class ShadowReportScreen extends StatefulWidget {
  final ShadowReport report;
  final VoidCallback onComplete;

  const ShadowReportScreen({
    super.key,
    required this.report,
    required this.onComplete,
  });

  @override
  State<ShadowReportScreen> createState() => _ShadowReportScreenState();
}

class _ShadowReportScreenState extends State<ShadowReportScreen> {
  late PageController _pageCtrl;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final name = r.personalityName;
    final typeLabel = '${r.mbtiType} · ${r.enneagramType}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Back / close
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ),
                const Spacer(),
                // Progress dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.purple
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const Spacer(),
                const SizedBox(width: 36), // balance
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Page Indicator Labels ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pageLabel(0, '面具'),
                _pageLabel(1, '陰影'),
                _pageLabel(2, '防禦'),
                _pageLabel(3, '壓抑'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // ─── PageView ───
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _PersonaPage(report: r, personalityName: name, typeLabel: typeLabel),
                _ShadowPage(report: r),
                _DefensePage(report: r),
                _RepressedPage(report: r, onComplete: widget.onComplete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageLabel(int index, String label) {
    final active = _currentPage == index;
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: GoogleFonts.notoSansTc(
        fontSize: 12,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        color: active ? AppColors.purple : AppColors.textMuted,
      ),
      child: Text(label),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Page 1: Persona
// ═══════════════════════════════════════════════════════════════

class _PersonaPage extends StatelessWidget {
  final ShadowReport report;
  final PersonalityName? personalityName;
  final String typeLabel;

  const _PersonaPage({
    required this.report,
    required this.personalityName,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = report.persona;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section label ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '① 你嘅面具',
              style: GoogleFonts.notoSansTc(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.cta,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Persona Name ───
          Text(
            p.name,
            style: GoogleFonts.notoSerifTc(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // ─── Type badge ───
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  typeLabel,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cta,
                  ),
                ),
              ),
              if (personalityName != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    personalityName!.nameCanto,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.purple,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // ─── Mask phrase ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cta.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cta.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Text('🎭', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p.maskPhrase,
                    style: GoogleFonts.notoSerifTc(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.cta,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Description ───
          Text(
            p.description,
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),

          // ─── Traits ───
          Text(
            '你嘅關鍵特質：',
            style: GoogleFonts.notoSansTc(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...p.traits.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.cta,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),

          // ─── Swipe hint ───
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '滑去下一頁',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Page 2: Shadow Pattern
// ═══════════════════════════════════════════════════════════════

class _ShadowPage extends StatelessWidget {
  final ShadowReport report;

  const _ShadowPage({required this.report});

  @override
  Widget build(BuildContext context) {
    final s = report.shadowPattern;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section label ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '② 你嘅陰影',
              style: GoogleFonts.notoSansTc(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.purple,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Shadow Name ───
          Text(
            s.name,
            style: GoogleFonts.notoSerifTc(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '你收埋咗嘅陰影模式',
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),

          // ─── Description ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌑', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.description,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Triggers ───
          Text(
            '咩情況下出現？',
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...s.triggerSituations.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('⚠️', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),

          // ─── Growth Hint ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sage.withValues(alpha: 0.12),
                  AppColors.sage.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.growthHint,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      color: AppColors.sage,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Swipe hint ───
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '滑去下一頁',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Page 3: Defense Mechanisms
// ═══════════════════════════════════════════════════════════════

class _DefensePage extends StatelessWidget {
  final ShadowReport report;

  const _DefensePage({required this.report});

  @override
  Widget build(BuildContext context) {
    final defenses = report.defenses;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section label ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mustard.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '③ 你嘅防禦機制',
              style: GoogleFonts.notoSansTc(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mustard,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '你唔覺意用緊嘅保護罩',
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),

          ...List.generate(defenses.length, (i) {
            final d = defenses[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _defenseCard(d, i == 0 ? '主要防禦' : '次要防禦'),
            );
          }),

          // ─── Swipe hint ───
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '滑去下一頁',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defenseCard(DefenseMechanism d, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mustard.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: GoogleFonts.notoSansTc(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.mustard,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            '🛡️ ${d.name}',
            style: GoogleFonts.notoSansTc(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            d.description,
            style: GoogleFonts.notoSansTc(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

          // Example
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mustard.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💬', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d.example,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Alternative
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌱', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  d.alternative,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12,
                    color: AppColors.sage,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Page 4: Repressed Functions + Completion
// ═══════════════════════════════════════════════════════════════

class _RepressedPage extends StatelessWidget {
  final ShadowReport report;
  final VoidCallback onComplete;

  const _RepressedPage({
    required this.report,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final funcs = report.repressedFunctions;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section label ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '④ 壓抑嘅認知功能',
              style: GoogleFonts.notoSansTc(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.sage,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '你成日忽略嘅 muscle',
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),

          ...List.generate(funcs.length, (i) {
            final f = funcs[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _functionCard(f),
            );
          }),

          const SizedBox(height: 12),

          // ─── Completion section ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.purple.withValues(alpha: 0.1),
                  AppColors.cta.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text('🎉', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  '你嘅 Shadow Report 完成咗！',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 反思問題：今日有冇用分析代替感受？',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Shadow Key ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '你嘅 Shadow Key',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '「${report.persona.name}」↔「${report.shadowPattern.name}」',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerifTc(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Done button ───
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: onComplete,
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
                      elevation: 0,
                    ),
                    child: const Text('繼續探索型得你'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _functionCard(RepressedFunction f) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('🧠', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  f.functionName,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            f.description,
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

          // Symptoms
          Text(
            '徵狀：',
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ...f.symptoms.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppColors.cta, fontSize: 12)),
                Expanded(
                  child: Text(
                    s,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),

          // Exercises
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✨', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '發展練習：',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sage,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...f.exercises.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• $e',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 12,
                            color: AppColors.sage,
                            height: 1.5,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

