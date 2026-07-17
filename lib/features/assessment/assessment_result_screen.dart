// ═══════════════════════════════════════════════════════════════════════
// AssessmentResultScreen — 結果頁 Edition 2
// Visual-heavy: large MBTI hero illustration, animated reveal, share card
// Daebi palette · HK Cantonese · flutter_animate staggered entrance
// ═══════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../personality_naming/naming_engine.dart';
import 'decision_tree_engine.dart';

// ─── MBTI visual data ──────────────────────────────────────────────────

/// Temperament group for colour assignment
enum MbtiTemperament {
  analyst,   // NT — Purple
  diplomat,  // NF — Coral
  sentinel,  // SJ — Sage
  explorer,  // SP — Mustard
}

/// Visual metadata per MBTI type
class _MbtiVisual {
  final String archetype;
  final String emoji;
  final MbtiTemperament temperament;
  final List<_Trait> traits;

  const _MbtiVisual({
    required this.archetype,
    required this.emoji,
    required this.temperament,
    required this.traits,
  });
}

class _Trait {
  final IconData icon;
  final String label;

  const _Trait({required this.icon, required this.label});
}

/// Colour & gradient for each temperament
extension _TemperamentColors on MbtiTemperament {
  Color get accent {
    switch (this) {
      case MbtiTemperament.analyst:
        return AppColors.purple;
      case MbtiTemperament.diplomat:
        return AppColors.cta;
      case MbtiTemperament.sentinel:
        return AppColors.sage;
      case MbtiTemperament.explorer:
        return AppColors.mustard;
    }
  }

  Color get accentLight => accent.withValues(alpha: 0.12);
}

final Map<String, _MbtiVisual> _mbtiVisuals = {
  'ENFJ': _MbtiVisual(
    archetype: '人群點燈者',
    emoji: '🌟',
    temperament: MbtiTemperament.diplomat,
    traits: [
      _Trait(icon: Icons.record_voice_over_rounded, label: '感染力強'),
      _Trait(icon: Icons.favorite_rounded, label: '有同理心'),
      _Trait(icon: Icons.explore_rounded, label: '善於引導'),
    ],
  ),
  'ENFP': _MbtiVisual(
    archetype: '靈感拓荒者',
    emoji: '🌈',
    temperament: MbtiTemperament.diplomat,
    traits: [
      _Trait(icon: Icons.auto_awesome_rounded, label: '充滿創意'),
      _Trait(icon: Icons.whatshot_rounded, label: '熱情洋溢'),
      _Trait(icon: Icons.flight_rounded, label: '隨性自由'),
    ],
  ),
  'ENTJ': _MbtiVisual(
    archetype: '宏圖指揮官',
    emoji: '👑',
    temperament: MbtiTemperament.analyst,
    traits: [
      _Trait(icon: Icons.flash_on_rounded, label: '果斷決策'),
      _Trait(icon: Icons.groups_rounded, label: '天生領袖'),
      _Trait(icon: Icons.psychology_rounded, label: '策略思維'),
    ],
  ),
  'ENTP': _MbtiVisual(
    archetype: '辯論發燒友',
    emoji: '🔥',
    temperament: MbtiTemperament.analyst,
    traits: [
      _Trait(icon: Icons.lightbulb_rounded, label: '機智聰敏'),
      _Trait(icon: Icons.forum_rounded, label: '熱衷辯論'),
      _Trait(icon: Icons.rocket_launch_rounded, label: '創新點子'),
    ],
  ),
  'ESFJ': _MbtiVisual(
    archetype: '社區大管家',
    emoji: '🤝',
    temperament: MbtiTemperament.sentinel,
    traits: [
      _Trait(icon: Icons.volunteer_activism_rounded, label: '樂於助人'),
      _Trait(icon: Icons.diversity_3_rounded, label: '社交能手'),
      _Trait(icon: Icons.check_circle_rounded, label: '盡責可靠'),
    ],
  ),
  'ESFP': _MbtiVisual(
    archetype: '派對心臟',
    emoji: '🎉',
    temperament: MbtiTemperament.explorer,
    traits: [
      _Trait(icon: Icons.celebration_rounded, label: '活在當下'),
      _Trait(icon: Icons.emoji_emotions_rounded, label: '開心果'),
      _Trait(icon: Icons.people_rounded, label: '喜歡熱鬧'),
    ],
  ),
  'ESTJ': _MbtiVisual(
    archetype: '人類閘機',
    emoji: '📋',
    temperament: MbtiTemperament.sentinel,
    traits: [
      _Trait(icon: Icons.fact_check_rounded, label: '實事求是'),
      _Trait(icon: Icons.trending_up_rounded, label: '執行力強'),
      _Trait(icon: Icons.inventory_2_rounded, label: '有條不紊'),
    ],
  ),
  'ESTP': _MbtiVisual(
    archetype: '行動特攻隊',
    emoji: '🎯',
    temperament: MbtiTemperament.explorer,
    traits: [
      _Trait(icon: Icons.directions_run_rounded, label: '行動派'),
      _Trait(icon: Icons.swap_horiz_rounded, label: '靈活變通'),
      _Trait(icon: Icons.explore_rounded, label: '大膽冒險'),
    ],
  ),
  'INFJ': _MbtiVisual(
    archetype: '靈魂解讀者',
    emoji: '🔮',
    temperament: MbtiTemperament.diplomat,
    traits: [
      _Trait(icon: Icons.visibility_rounded, label: '直覺敏銳'),
      _Trait(icon: Icons.psychology_rounded, label: '洞悉人心'),
      _Trait(icon: Icons.auto_awesome_rounded, label: '理想主義'),
    ],
  ),
  'INFP': _MbtiVisual(
    archetype: '內心詩人',
    emoji: '🌙',
    temperament: MbtiTemperament.diplomat,
    traits: [
      _Trait(icon: Icons.auto_stories_rounded, label: '內心豐富'),
      _Trait(icon: Icons.favorite_border_rounded, label: '忠於價值'),
      _Trait(icon: Icons.healing_rounded, label: '善解人意'),
    ],
  ),
  'INTJ': _MbtiVisual(
    archetype: '戰略軍師',
    emoji: '♟️',
    temperament: MbtiTemperament.analyst,
    traits: [
      _Trait(icon: Icons.travel_explore_rounded, label: '高瞻遠矚'),
      _Trait(icon: Icons.psychology_rounded, label: '獨立思考'),
      _Trait(icon: Icons.star_rounded, label: '追求完美'),
    ],
  ),
  'INTP': _MbtiVisual(
    archetype: '理論工程師',
    emoji: '⚙️',
    temperament: MbtiTemperament.analyst,
    traits: [
      _Trait(icon: Icons.manage_search_rounded, label: '分析力強'),
      _Trait(icon: Icons.menu_book_rounded, label: '熱衷理論'),
      _Trait(icon: Icons.emoji_objects_rounded, label: '創新思維'),
    ],
  ),
  'ISFJ': _MbtiVisual(
    archetype: '人肉暖爐',
    emoji: '🏡',
    temperament: MbtiTemperament.sentinel,
    traits: [
      _Trait(icon: Icons.self_improvement_rounded, label: '溫柔體貼'),
      _Trait(icon: Icons.favorite_rounded, label: '細心關懷'),
      _Trait(icon: Icons.shield_rounded, label: '忠誠可靠'),
    ],
  ),
  'ISFP': _MbtiVisual(
    archetype: '低調藝術家',
    emoji: '🎨',
    temperament: MbtiTemperament.explorer,
    traits: [
      _Trait(icon: Icons.palette_rounded, label: '藝術天份'),
      _Trait(icon: Icons.spa_rounded, label: '隨和低調'),
      _Trait(icon: Icons.hearing_rounded, label: '感受力強'),
    ],
  ),
  'ISTJ': _MbtiVisual(
    archetype: '可靠支柱',
    emoji: '⚖️',
    temperament: MbtiTemperament.sentinel,
    traits: [
      _Trait(icon: Icons.shield_rounded, label: '穩重可靠'),
      _Trait(icon: Icons.assignment_rounded, label: '責任感強'),
      _Trait(icon: Icons.height_rounded, label: '一絲不苟'),
    ],
  ),
  'ISTP': _MbtiVisual(
    archetype: '沉默工匠',
    emoji: '🔧',
    temperament: MbtiTemperament.explorer,
    traits: [
      _Trait(icon: Icons.build_rounded, label: '動手能力強'),
      _Trait(icon: Icons.thermostat_rounded, label: '冷靜分析'),
      _Trait(icon: Icons.flight_rounded, label: '獨立自主'),
    ],
  ),
};

// ─── Screen ────────────────────────────────────────────────────────────

class AssessmentResultScreen extends ConsumerStatefulWidget {
  final String mbti;
  final String ennea;
  final DecisionTreeEngine engine;
  final void Function(String mbti, String ennea) onComplete;

  const AssessmentResultScreen({
    super.key,
    required this.mbti,
    required this.ennea,
    required this.engine,
    required this.onComplete,
  });

  @override
  ConsumerState<AssessmentResultScreen> createState() =>
      _AssessmentResultScreenState();
}

class _AssessmentResultScreenState
    extends ConsumerState<AssessmentResultScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _shareCardKey = GlobalKey();
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_done', true);
    await prefs.setString('mbti', widget.mbti);
    await prefs.setString('ennea', widget.ennea);
  }

  // ─── Share as image card ──────────────────────────────────────────────

  Future<void> _shareCard() async {
    if (_capturing) return;
    setState(() => _capturing = true);

    try {
      final boundary = _shareCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/typingself_share.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '型得你 — 我係${widget.mbti}',
      );
    } catch (_) {
      // Fallback: text share
      final name = NamingEngine.getName(widget.mbti, widget.ennea) ??
          PersonalityName(
            mbti: widget.mbti,
            enneagram: widget.ennea,
            healthLevel: 'healthy',
            nameCanto: '探索者',
            tagline: '你仲喺度了解緊自己，慢慢嚟',
            encourage: '',
            emoji: '🧠',
          );
      final text = '我係 ${name.mbti} ${name.enneagram}：${name.nameCanto} ${name.emoji}\n'
          '${name.tagline}\n\n'
          '「型得你」— 了解自己，贏返自己\n'
          '下載：https://xingdeni.app';
      await Share.share(text, subject: '型得你 — 我係${widget.mbti}');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final visual = _mbtiVisuals[widget.mbti] ?? _mbtiVisuals['ENFJ']!;
    final accent = visual.temperament.accent;
    final accentLight = visual.temperament.accentLight;

    final name = NamingEngine.getName(widget.mbti, widget.ennea) ??
        PersonalityName(
          mbti: widget.mbti,
          enneagram: widget.ennea,
          healthLevel: 'healthy',
          nameCanto: '探索者',
          tagline: '你仲喺度了解緊自己，慢慢嚟',
          encourage: '',
          emoji: visual.emoji,
        );
    // Use the type-specific emoji if NamingEngine didn't provide a unique one
    final displayEmoji = name.emoji == '🧠' ? visual.emoji : name.emoji;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ─── 1. Header ──────────────────────────────────────────────
              _buildHeader(accent)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.03, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 20),

              // ─── 2. Share card (capturable) ─────────────────────────────
              RepaintBoundary(
                key: _shareCardKey,
                child: _ShareCardContent(
                  mbti: widget.mbti,
                  ennea: widget.ennea,
                  visual: visual,
                  name: name,
                  displayEmoji: displayEmoji,
                  accent: accent,
                ),
              ),

              const SizedBox(height: 16),

              // ─── 3. Key traits ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildTraits(visual, accentLight, accent),
              ),

              const SizedBox(height: 20),

              // ─── 4. Tagline ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildTagline(name.tagline, accent, accentLight),
              ),

              const SizedBox(height: 24),

              // ─── 5. Actions ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildActions(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader(Color accent) {
    return Column(
      children: [
        Text(
          '🎉 結果出嚟啦！',
          style: GoogleFonts.notoSerifTc(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '你係⋯⋯',
          style: GoogleFonts.notoSansTc(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Share Card Content ──────────────────────────────────────────────

  // ─── Traits ──────────────────────────────────────────────────────────

  Widget _buildTraits(
      _MbtiVisual visual, Color accentLight, Color accent) {
    final items = visual.traits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            '🧩 你嘅關鍵特質',
            style: GoogleFonts.notoSansTc(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...List.generate(items.length, (i) {
          final delay = 350 + (i * 120);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TraitCard(
              icon: items[i].icon,
              label: items[i].label,
              accent: accent,
              accentLight: accentLight,
            ).animate().fadeIn(
                  duration: 300.ms,
                  delay: delay.ms,
                ).slideX(
                  begin: 0.04,
                  duration: 300.ms,
                  delay: delay.ms,
                  curve: Curves.easeOutCubic,
                ),
          );
        }),
      ],
    );
  }

  // ─── Tagline ─────────────────────────────────────────────────────────

  Widget _buildTagline(String tagline, Color accent, Color accentLight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💬',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '「${tagline}」',
              style: GoogleFonts.notoSerifTc(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: 700.ms,
        ).slideY(begin: 0.04, duration: 400.ms, delay: 700.ms, curve: Curves.easeOutCubic);
  }

  // ─── Actions ─────────────────────────────────────────────────────────

  Widget _buildActions() {
    return Column(
      children: [
        // Share button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: _capturing ? null : _shareCard,
            icon: _capturing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.image_rounded, size: 20),
            label: Text(
              '📸 Share 靚卡俾朋友',
              style: GoogleFonts.notoSansTc(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
          ),
        ).animate().fadeIn(
              duration: 400.ms,
              delay: 900.ms,
            ).slideY(
                begin: 0.04,
                duration: 400.ms,
                delay: 900.ms,
                curve: Curves.easeOutCubic),

        const SizedBox(height: 12),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
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
                const Text('開始使用型得你'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ).animate().fadeIn(
              duration: 400.ms,
              delay: 1100.ms,
            ).slideY(
                begin: 0.04,
                duration: 400.ms,
                delay: 1100.ms,
                curve: Curves.easeOutCubic),

        const SizedBox(height: 8),

        TextButton(
          onPressed: _retakeTest,
          child: Text(
            '再測一次',
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ).animate().fadeIn(
              duration: 300.ms,
              delay: 1200.ms,
            ),
      ],
    );
  }

  // ─── Callbacks ───────────────────────────────────────────────────────

  void _onContinue() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('mbti', widget.mbti);
      prefs.setString('ennea', widget.ennea);
      try {
        prefs.setDouble(
            'mbti_confidence', widget.engine.state.mbtiConfidence.toDouble());
        prefs.setDouble(
            'ennea_confidence', widget.engine.state.enneaConfidence.toDouble());
        prefs.setBool('mbti_verified', widget.engine.state.mbtiVerified);
        prefs.setBool('ennea_verified', widget.engine.state.enneaVerified);
        prefs.setInt('total_questions', widget.engine.answeredCount);
        prefs.setString('mbti_result', widget.engine.state.mbtiString);
        prefs.setString('ennea_result', widget.engine.state.enneagramKey);
      } catch (_) {
        // Non-critical
      }
    });
    widget.onComplete(widget.mbti, widget.ennea);
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _retakeTest() {
    widget.engine.reset();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('test_done', false);
      prefs.remove('mbti');
      prefs.remove('ennea');
    });
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

// ─── Hero Visual Card ─────────────────────────────────────────────────

class _MbtiHeroCard extends StatelessWidget {
  final Color accent;
  final Color accentLight;
  final String mbti;
  final String ennea;
  final String emoji;
  final String archetype;
  final String nameCanto;

  const _MbtiHeroCard({
    required this.accent,
    required this.accentLight,
    required this.mbti,
    required this.ennea,
    required this.emoji,
    required this.archetype,
    required this.nameCanto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent,
            accent.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                // Emoji
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 16),

                // MBTI type — large visual focus
                Text(
                  mbti,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),

                // Archetype
                Text(
                  archetype,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),

                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '$mbti · $ennea',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    nameCanto,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerifTc(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
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

// ─── Trait Card ───────────────────────────────────────────────────────

class _TraitCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final Color accentLight;

  const _TraitCard({
    required this.icon,
    required this.label,
    required this.accent,
    required this.accentLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 22,
              color: accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSansTc(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: accent.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

// ─── Full Share Card Content (wraps everything capturable) ───────────

class _ShareCardContent extends StatelessWidget {
  final String mbti;
  final String ennea;
  final _MbtiVisual visual;
  final PersonalityName name;
  final String displayEmoji;
  final Color accent;

  const _ShareCardContent({
    required this.mbti,
    required this.ennea,
    required this.visual,
    required this.name,
    required this.displayEmoji,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _MbtiHeroCard(
        accent: accent,
        accentLight: visual.temperament.accentLight,
        mbti: mbti,
        ennea: ennea,
        emoji: displayEmoji,
        archetype: visual.archetype,
        nameCanto: name.nameCanto,
      ),
    );
  }
}
