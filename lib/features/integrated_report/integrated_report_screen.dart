// ═══════════════════════════════════════════════════════════════════════
// IntegratedReportScreen — Stage 4 整合報告
// Single scrollable page combining all 3 stages into one unified view:
//   ① TypeSoul Profile   ② Shadow Report   ③ Growth Plan
// Daebi palette · HK Cantonese tone · flutter analyze pass
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../typesoul/typesoul.dart';
import '../typesoul/typesoul_engine.dart';
import '../personality_naming/naming_engine.dart';
import '../shadow_report/shadow_report_engine.dart';
import '../growth/inferior_function_data.dart';
import '../growth/growth_service.dart';

// ─────────────────────────────────────────────────────────────────────
// Screen — Entry point for the integrated report
// ─────────────────────────────────────────────────────────────────────

class IntegratedReportScreen extends StatefulWidget {
  final String mbti;
  final String ennea;

  const IntegratedReportScreen({
    super.key,
    required this.mbti,
    required this.ennea,
  });

  @override
  State<IntegratedReportScreen> createState() => _IntegratedReportScreenState();
}

class _IntegratedReportScreenState extends State<IntegratedReportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  bool _ready = false;
  bool _showAll = false;

  // Stage 1 — TypeSoul
  TypeSoul? _typeSoul;
  PersonalityName? _name;

  // Stage 2 — Shadow
  ShadowReport? _shadowReport;

  // Stage 3 — Growth
  InferiorFunctionInfo? _infInfo;
  int _streak = 0;
  int _totalPractices = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Stage 1
    _typeSoul = TypeSoulEngine.lookUp(widget.mbti, widget.ennea);
    _name = NamingEngine.getName(widget.mbti, widget.ennea);

    // Stage 2
    final engine = ShadowReportEngine();
    _shadowReport = engine.generate(widget.mbti, widget.ennea);

    // Stage 3
    _infInfo = getInferiorFunctionInfo(widget.mbti);
    _streak = await GrowthService.getStreak();
    _totalPractices = await GrowthService.getTotalPractices();

    if (!mounted) return;
    setState(() => _ready = true);
    _animCtrl.forward();
    // Slight delay then reveal all sections
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _showAll = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
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
                const SizedBox(width: 10),
                Text(
                  '完整報告',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _shareReport,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.share_rounded, size: 18, color: AppColors.cta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _ready ? _buildReport() : _buildLoading(),
    );
  }

  // ──── Loading ────
  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 28, height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.cta),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN REPORT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReport() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ─── Hero Section ───
          _buildHeroSection(),

          // ─── Stage 1: TypeSoul ───
          if (_showAll) _buildDivider('Stage 1', '型格解讀'),

          if (_showAll && _typeSoul != null) ...[
            _buildStageCard(
              icon: '🎭',
              title: '你嘅核心型格',
              color: AppColors.cta,
              delay: 100,
              child: _buildTypeSoulSection(_typeSoul!),
            ),
          ],

          // ─── Stage 2: Shadow Report ───
          if (_showAll) _buildDivider('Stage 2', 'Shadow 暗影報告'),

          if (_showAll && _shadowReport != null) ...[
            _buildStageCard(
              icon: '🌑',
              title: '面具 · 陰影 · 防禦',
              color: AppColors.purple,
              delay: 200,
              child: _buildShadowSection(_shadowReport!),
            ),
          ],

          // ─── Stage 3: Growth ───
          if (_showAll) _buildDivider('Stage 3', '成長整合'),

          if (_showAll) ...[
            _buildStageCard(
              icon: '🌱',
              title: '每日成長練習',
              color: AppColors.sage,
              delay: 300,
              child: _buildGrowthSection(),
            ),
          ],

          // ─── Final Summary ───
          if (_showAll) _buildFinalSummary(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    final emoji = _typeSoul?.emoji ?? _name?.emoji ?? '🧠';
    final cantoName = _typeSoul?.nameCanto ?? _name?.nameCanto ?? '探索者';
    final tagline = _name?.tagline ?? '了解自己，贏返自己';
    final typeLabel = '${widget.mbti} · ${widget.ennea}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cta.withValues(alpha: 0.85),
            AppColors.purple.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.cta.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 34))),
          ).animate(controller: _animCtrl)
            .scaleXY(begin: 0, end: 1, duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(
            cantoName,
            style: GoogleFonts.notoSerifTc(
              fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2,
            ),
          ).animate(controller: _animCtrl, delay: 100.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.03, duration: 400.ms),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              typeLabel,
              style: GoogleFonts.notoSansTc(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ).animate(controller: _animCtrl, delay: 200.ms)
            .fadeIn(duration: 400.ms)
            .scale(duration: 400.ms),
          const SizedBox(height: 14),
          Text(
            tagline,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifTc(
              fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ).animate(controller: _animCtrl, delay: 300.ms)
            .fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          // Stage progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _progressDot('① 型格', AppColors.cta),
              const SizedBox(width: 8),
              Container(width: 20, height: 1, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(width: 8),
              _progressDot('② 暗影', AppColors.purple),
              const SizedBox(width: 8),
              Container(width: 20, height: 1, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(width: 8),
              _progressDot('③ 成長', AppColors.sage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressDot(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: GoogleFonts.notoSansTc(
        fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9),
      )),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STAGE 1 — TypeSoul
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTypeSoulSection(TypeSoul ts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Core description (abbreviated)
        Text(
          ts.coreDescription.replaceAll('\\n', '\n').length > 200
              ? '${ts.coreDescription.replaceAll('\\n', '\n').substring(0, 200)}…'
              : ts.coreDescription.replaceAll('\\n', '\n'),
          style: GoogleFonts.notoSansTc(
            fontSize: 13, color: AppColors.textPrimary, height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        // Superpowers (top 2)
        _miniHeader('🎯 超能力'),
        const SizedBox(height: 6),
        ...ts.superpowers.take(2).map((sp) => _bulletItem(sp, AppColors.sage)),
        if (ts.superpowers.length > 2)
          Text('+${ts.superpowers.length - 2} 更多…', style: TextStyle(
            fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic,
          )),
        const SizedBox(height: 12),
        // Blindspots (top 2)
        _miniHeader('⚠️ 盲點'),
        const SizedBox(height: 6),
        ...ts.blindspots.take(2).map((bp) => _bulletItem(bp, AppColors.cta)),
        if (ts.blindspots.length > 2)
          Text('+${ts.blindspots.length - 2} 更多…', style: TextStyle(
            fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic,
          )),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STAGE 2 — Shadow Report
  // ═══════════════════════════════════════════════════════════════
  Widget _buildShadowSection(ShadowReport sr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Persona ↔ Shadow key
        _dualKey(
          '🎭 面具', sr.persona.name,
          '🌑 陰影', sr.shadowPattern.name,
        ),
        const SizedBox(height: 16),
        // Mask Phrase
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cta.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cta.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Text('🎭', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sr.persona.maskPhrase,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 13, fontStyle: FontStyle.italic,
                    color: AppColors.cta, height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Primary Defense
        if (sr.defenses.isNotEmpty) ...[
          _miniHeader('🛡️ 主要防禦機制'),
          const SizedBox(height: 6),
          Text(
            sr.defenses.first.name,
            style: GoogleFonts.notoSansTc(
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sr.defenses.first.description.substring(0, sr.defenses.first.description.length.clamp(0, 120)),
            style: GoogleFonts.notoSansTc(
              fontSize: 12, color: AppColors.textSecondary, height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 14),
        // Repressed functions summary
        _miniHeader('🧠 壓抑嘅認知功能'),
        const SizedBox(height: 6),
        ...sr.repressedFunctions.take(1).map((rf) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '• ${rf.functionName}：${rf.description.substring(0, rf.description.length.clamp(0, 80))}',
            style: GoogleFonts.notoSansTc(
              fontSize: 12, color: AppColors.textSecondary, height: 1.5,
            ),
          ),
        )),
        const SizedBox(height: 10),
        // Shadow Key insight
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sr.shadowPattern.growthHint,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12, color: AppColors.purple, height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STAGE 3 — Growth
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGrowthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inferior function
        if (_infInfo != null) ...[
          _miniHeader('🧩 你嘅弱勢功能'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.sage.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('🕶️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _infInfo!.functionName,
                        style: GoogleFonts.notoSerifTc(
                          fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _infInfo!.description,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 12, color: AppColors.textSecondary, height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Daily task
        if (_infInfo != null) ...[
          _miniHeader('📝 今日練習'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text('🎯', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _infInfo!.dailyTask,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13, color: AppColors.textPrimary, height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Stats
        _miniHeader('📊 成長統計'),
        const SizedBox(height: 6),
        Row(
          children: [
            _statChip('🔥', '連續 $_streak 日', AppColors.cta),
            const SizedBox(width: 8),
            _statChip('✅', '共 $_totalPractices 次', AppColors.sage),
          ],
        ),
        const SizedBox(height: 14),

        // Grip warning
        if (_infInfo != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mustard.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mustard.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('壓力預警（Inferior Grip）',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mustard,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _infInfo!.gripWarning,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 12, color: AppColors.textSecondary, height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FINAL SUMMARY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFinalSummary() {
    final encourage = _name?.encourage ?? '了解自己，贏返自己';
    final cantoName = _typeSoul?.nameCanto ?? _name?.nameCanto ?? '探索者';
    final personaName = _shadowReport?.persona.name ?? cantoName;
    final shadowName = _shadowReport?.shadowPattern.name ?? '未知';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.cta.withValues(alpha: 0.08),
              AppColors.purple.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cta.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text('🌟', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              '你嘅整合旅程',
              style: GoogleFonts.notoSerifTc(
                fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '面具「$personaName」⇢ 暗影「$shadowName」⇢ 成長',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTc(
                fontSize: 12, color: AppColors.textSecondary, height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                encourage,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerifTc(
                  fontSize: 14, fontStyle: FontStyle.italic,
                  color: AppColors.cta, height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _shareReport,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share 完整報告'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: GoogleFonts.notoSansTc(
                    fontSize: 15, fontWeight: FontWeight.w700,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, duration: 500.ms),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHARING
  // ═══════════════════════════════════════════════════════════════
  void _shareReport() {
    final cantoName = _typeSoul?.nameCanto ?? _name?.nameCanto ?? '探索者';
    final typeLabel = '${widget.mbti} · ${widget.ennea}';
    final personaName = _shadowReport?.persona.name ?? cantoName;
    final shadowName = _shadowReport?.shadowPattern.name ?? '未知';
    final maskPhrase = _shadowReport?.persona.maskPhrase ?? '';
    final infFunc = _infInfo?.functionName ?? '';
    final task = _infInfo?.dailyTask ?? '';
    final tagline = _name?.tagline ?? '';

    final text = '''
📋 我嘅完整人格報告

🏷️ $typeLabel · $cantoName
$tagline

🎭 Stage 1 — 型格
${_typeSoul?.coreDescription.replaceAll('\\n', ' ').substring(0, (_typeSoul?.coreDescription.length ?? 100).clamp(0, 150)) ?? '探索中'}…

🌑 Stage 2 — Shadow
面具：$personaName ｜ 陰影：$shadowName
「$maskPhrase」

🌱 Stage 3 — 成長
弱勢功能：$infFunc
今日練習：$task

了解自己，贏返自己
@typingself
''';

    Share.share(text.trim(), subject: '📋 我嘅完整人格報告 — @typingself');
  }

  // ═══════════════════════════════════════════════════════════════
  // REUSABLE COMPONENTS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDivider(String stage, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(stage, style: GoogleFonts.notoSansTc(
              fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5,
            )),
          ),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.notoSerifTc(
            fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
          )),
          const Spacer(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStageCard({
    required String icon,
    required String title,
    required Color color,
    required int delay,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(icon, style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay))
        .slideY(begin: 0.04, duration: 400.ms, delay: Duration(milliseconds: delay)),
    );
  }

  Widget _miniHeader(String text) {
    return Text(text, style: GoogleFonts.notoSansTc(
      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    ));
  }

  Widget _bulletItem(String text, Color accent) {
    final clean = text.replaceAll('**', '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6, height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(clean, style: GoogleFonts.notoSansTc(
              fontSize: 12, color: AppColors.textSecondary, height: 1.5,
            )),
          ),
        ],
      ),
    );
  }

  Widget _dualKey(String label1, String value1, String label2, String value2) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(height: 3),
                Text(value1, style: GoogleFonts.notoSerifTc(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.cta,
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('⇢', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label2, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(height: 3),
                Text(value2, style: GoogleFonts.notoSerifTc(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.purple,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.notoSansTc(
            fontSize: 13, fontWeight: FontWeight.w600, color: color,
          )),
        ],
      ),
    );
  }
}
