// ═══════════════════════════════════════════════════════════════════════
// AssessmentResultScreen — 結果頁 Edition 2
// Visual-heavy: large MBTI hero illustration, animated reveal, share card
// Daebi palette · HK Cantonese · flutter_animate staggered entrance
// P2.1+P2.2: Wing type analysis + CustomPainter bar chart for MBTI % + Enneagram top 3
// ═══════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../core/analytics_service.dart';
import '../../core/celebration_overlay.dart';
import '../personality_naming/naming_engine.dart';
import '../shadow_report/shadow_report_engine.dart';
import '../shadow_report/shadow_report_screen.dart';
import 'decision_tree_engine.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

// ─── Enneagram wing type descriptions (HK Cantonese) ───────────────────

/// Wing type explanation: what it means when a core type is influenced
/// by its adjacent wing.
const Map<int, String> _wingDescriptions = {
  1: 'Type 1 受翼型影響：你嘅完美主義唔再孤單——\n'
      '• w9：更溫和包容，多咗一份從容，追求秩序但唔急燥\n'
      '• w2：更關心人，會用幫助人嘅方式去實踐理想',
  2: 'Type 2 受翼型影響：你嘅付出方式有兩種 flavour——\n'
      '• w1：更有原則，幫人嘅時候有底線同標準\n'
      '• w3：更有魅力，付出嘅同時都想得到認同同讚賞',
  3: 'Type 3 受翼型影響：你追求成功嘅方式有唔同層次——\n'
      '• w2：更有人情味，成就建基於人際關係\n'
      '• w4：更有個性，追求 authentic 嘅成功多過表面光環',
  4: 'Type 4 受翼型影響：你獨特嘅表達方式有兩種方向——\n'
      '• w3：更外向進取，鍾意將創意展現俾人睇\n'
      '• w5：更內向深沉，用知識同觀察去理解世界',
  5: 'Type 5 受翼型影響：你追求知識嘅風格有兩種——\n'
      '• w4：更有直覺同創造力，唔止理性仲有藝術感\n'
      '• w6：更謹慎忠誠，將知識用嚟應對風險同保護團隊',
  6: 'Type 6 受翼型影響：你應對世界嘅方式有兩個面向——\n'
      '• w5：更理性分析，用思維去化解內心嘅不安\n'
      '• w7：更積極樂觀，用活動同計劃去分散焦慮',
  7: 'Type 7 受翼型影響：你享受生活嘅 style 有兩種——\n'
      '• w6：更負責任，玩得嚟都會諗到風險同後果\n'
      '• w8：更具主導性，享受中帶有控制權同影響力',
  8: 'Type 8 受翼型影響：你展現力量嘅方式有兩種——\n'
      '• w7：更外向享樂，用精力同魅力去開拓新領域\n'
      '• w9：更沉穩包容，用溫柔嘅方式去保護同帶領',
  9: 'Type 9 受翼型影響：你追求和諧嘅路徑有兩種——\n'
      '• w8：更有主見，和諧唔代表退讓，仲可以企硬\n'
      '• w1：更有原則，追求平靜同時都堅守自己嘅價值',
};

/// Human-friendly wing type names
const Map<int, String> _wingTypeNames = {
  1: '改革者',
  2: '助人者',
  3: '成就者',
  4: '獨特者',
  5: '思考者',
  6: '忠誠者',
  7: '享樂者',
  8: '挑戰者',
  9: '和平者',
};

// ─── CustomPainter: bar chart for MBTI % + Enneagram top 3 ────────────

class _BarChartPainter extends CustomPainter {
  final List<_ChartBar> bars;
  final Color accent;
  final Color accentLight;

  _BarChartPainter({
    required this.bars,
    required this.accent,
    required this.accentLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    const double rowHeight = 34.0;
    const double gap = 6.0;
    const double labelWidth = 56.0;
    const double barRadius = 6.0;
    const double valueWidth = 46.0;
    final double barMaxWidth = size.width - labelWidth - valueWidth - 20;

    final Paint bgPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final y = i * (rowHeight + gap) + 4;

      // --- Background track ---
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(labelWidth, y, barMaxWidth, rowHeight - 4),
        const Radius.circular(barRadius),
      );
      canvas.drawRRect(bgRect, bgPaint);

      // --- Filled bar ---
      final fillW = (bar.fraction * barMaxWidth).clamp(0.0, barMaxWidth);
      if (fillW > 0) {
        // Use a shader that covers the full draw area but clips naturally
        final barFillPaint = Paint()
          ..shader = LinearGradient(
            colors: [accent.withValues(alpha: 0.8), accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Rect.fromLTWH(labelWidth, y, fillW, rowHeight - 4));

        final fillRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(labelWidth, y, fillW, rowHeight - 4),
          Radius.circular(barRadius),
        );
        canvas.drawRRect(fillRect, barFillPaint);
      }

      // --- Label text (left side) ---
      final labelTp = TextPainter(
        text: TextSpan(
          text: bar.label,
          style: GoogleFonts.notoSansTc(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      )..layout(maxWidth: labelWidth - 4);
      labelTp.paint(
        canvas,
        Offset(labelWidth - labelTp.width - 4, y + (rowHeight - 4 - labelTp.height) / 2),
      );

      // --- Value text (right side) ---
      final valueTp = TextPainter(
        text: TextSpan(
          text: bar.valueText,
          style: GoogleFonts.notoSansTc(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valueTp.paint(
        canvas,
        Offset(
          size.width - valueWidth + (valueWidth - valueTp.width) / 2,
          y + (rowHeight - 4 - valueTp.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}

class _ChartBar {
  final String label;
  final double fraction;
  final String valueText;

  const _ChartBar({
    required this.label,
    required this.fraction,
    required this.valueText,
  });
}

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
    await prefs.setBool('stage1_done', true);
    await prefs.setString('mbti', widget.mbti);
    await prefs.setString('ennea', widget.ennea);

    // Log analytics
    AnalyticsService.log(AnalyticsService.testCompleted, properties: {
      'mbti': widget.mbti,
      'ennea': widget.ennea,
    });

    // Show celebration overlay for Stage 1 completion
    if (mounted) {
      CelebrationOverlay.show(
        context,
        emoji: '🎉',
        title: 'Stage 1 完成！',
        subtitle: '你已經了解咗你嘅 MBTI 同 Enneagram 🧠\n下一站：Shadow Report 陰影報告 🌑',
        accent: _mbtiVisuals[widget.mbti]?.temperament.accent ?? AppColors.cta,
      );
    }

    // Log result_viewed
    AnalyticsService.log(AnalyticsService.resultViewed, properties: {
      'mbti': widget.mbti,
      'ennea': widget.ennea,
    });
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

  // ─── Compute MBTI dimension percentages from engine state ─────────────

  List<_ChartBar> _buildMbtiChartBars(Color accent) {
    final s = widget.engine.state;
    final bars = <_ChartBar>[];

    // E / I
    final eiTotal = s.e + s.i;
    if (eiTotal > 0) {
      final ePct = (s.e / eiTotal * 100).round();
      final iPct = (s.i / eiTotal * 100).round();
      final dominant = s.e >= s.i;
      bars.add(_ChartBar(
        label: 'E / I',
        fraction: dominant ? ePct / 100.0 : iPct / 100.0,
        valueText: dominant ? '${ePct}% E' : '${iPct}% I',
      ));
    }

    // S / N
    final snTotal = s.s + s.n;
    if (snTotal > 0) {
      final sPct = (s.s / snTotal * 100).round();
      final nPct = (s.n / snTotal * 100).round();
      final dominant = s.s >= s.n;
      bars.add(_ChartBar(
        label: 'S / N',
        fraction: dominant ? sPct / 100.0 : nPct / 100.0,
        valueText: dominant ? '${sPct}% S' : '${nPct}% N',
      ));
    }

    // T / F
    final tfTotal = s.t + s.f;
    if (tfTotal > 0) {
      final tPct = (s.t / tfTotal * 100).round();
      final fPct = (s.f / tfTotal * 100).round();
      final dominant = s.t >= s.f;
      bars.add(_ChartBar(
        label: 'T / F',
        fraction: dominant ? tPct / 100.0 : fPct / 100.0,
        valueText: dominant ? '${tPct}% T' : '${fPct}% F',
      ));
    }

    // J / P
    final jpTotal = s.j + s.p;
    if (jpTotal > 0) {
      final jPct = (s.j / jpTotal * 100).round();
      final pPct = (s.p / jpTotal * 100).round();
      final dominant = s.j >= s.p;
      bars.add(_ChartBar(
        label: 'J / P',
        fraction: dominant ? jPct / 100.0 : pPct / 100.0,
        valueText: dominant ? '${jPct}% J' : '${pPct}% P',
      ));
    }

    return bars;
  }

  /// Enneagram top 3, each as a fraction of max possible for the chart
  List<_ChartBar> _buildEnneaTop3(Color accent) {
    final scores = widget.engine.state.enneaTypeScores;
    final maxScore = scores.reduce(math.max);
    // Build labelled entries, sort descending, take top 3
    final indexed = <_IndexedScore>[];
    for (int i = 0; i < 9; i++) {
      indexed.add(_IndexedScore(type: i + 1, score: scores[i]));
    }
    indexed.sort((a, b) => b.score.compareTo(a.score));
    final top3 = indexed.take(3).toList();

    // For visual fraction, use max-score as 1.0 so tallest bar always fills
    final scale = maxScore > 0 ? 1.0 / maxScore : 1.0;

    return top3.map((e) {
      final typeName = _wingTypeNames[e.type] ?? 'Type ${e.type}';
      final pct = maxScore > 0 ? (e.score / maxScore * 100).round() : 0;
      return _ChartBar(
        label: '${e.type} ${typeName}',
        fraction: e.score * scale,
        valueText: '${pct}%',
      );
    }).toList();
  }

  // ─── Wing type data ──────────────────────────────────────────────────

  String _wingAnalysisText(String enneaKey) {
    // Parse e.g. "4w3" -> coreType=4, wing=3
    final parts = enneaKey.split('w');
    if (parts.length != 2) return '';
    final coreType = int.tryParse(parts[0]);
    if (coreType == null || coreType < 1 || coreType > 9) return '';

    final description = _wingDescriptions[coreType] ?? '';
    if (description.isEmpty) return '';
    return description;
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

              const SizedBox(height: 28),

              // ─── 5. MBTI dimension bar chart ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildMbtiChartSection(accent, accentLight),
              ),

              const SizedBox(height: 28),

              // ─── 6. Enneagram top 3 bar chart ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildEnneaChartSection(accent, accentLight),
              ),

              const SizedBox(height: 28),

              // ─── 7. Wing type analysis ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildWingAnalysisSection(accent, accentLight),
              ),

              const SizedBox(height: 28),

              // ─── 8. Actions ─────────────────────────────────────────────
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

  // ─── MBTI Bar Chart ──────────────────────────────────────────────────

  Widget _buildMbtiChartSection(Color accent, Color accentLight) {
    final mbtiBars = _buildMbtiChartBars(accent);
    return _ChartSection(
      title: '📊 MBTI 維度傾向',
      subtitle: '各維度嘅優勢百分比',
      bars: mbtiBars,
      accent: accent,
      accentLight: accentLight,
      chartHeight: (mbtiBars.length * 40.0) + 8,
    );
  }

  // ─── Enneagram Top 3 Chart ───────────────────────────────────────────

  Widget _buildEnneaChartSection(Color accent, Color accentLight) {
    final enneaBars = _buildEnneaTop3(accent);
    return _ChartSection(
      title: '🔢 九型人格 Top 3',
      subtitle: '最高分嘅三種型號傾向',
      bars: enneaBars,
      accent: accent,
      accentLight: accentLight,
      chartHeight: (enneaBars.length * 40.0) + 8,
    );
  }

  // ─── Wing Analysis ───────────────────────────────────────────────────

  Widget _buildWingAnalysisSection(Color accent, Color accentLight) {
    final wingText = _wingAnalysisText(widget.ennea);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🪶 翼型分析',
                style: GoogleFonts.notoSansTc(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.ennea,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (wingText.isNotEmpty)
            Text(
              wingText,
              style: GoogleFonts.notoSansTc(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            )
          else
            Text(
              '你嘅九型人格係 ${widget.ennea}，翼型影響住你核心型號嘅表達方式。',
              style: GoogleFonts.notoSansTc(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 650.ms)
        .slideY(begin: 0.04, duration: 400.ms, delay: 650.ms, curve: Curves.easeOutCubic);
  }

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
    final accent = _mbtiVisuals[widget.mbti]?.temperament.accent ?? AppColors.purple;
    return Column(
      children: [
        // ── Guidance section header ──
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '下一步做咩好？',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
              duration: 300.ms,
              delay: 800.ms,
            ),

        // ── Guidance: Shadow Report ──
        _GuidanceButton(
          emoji: '🌑',
          title: '探索陰影自我',
          subtitle: '了解你收埋咗嘅另一面',
          accent: accent,
          delay: 850,
          onTap: _openShadowReport,
        ),

        const SizedBox(height: 10),

        // ── Guidance: Set Reminder ──
        _GuidanceButton(
          emoji: '⏰',
          title: '設定每日提醒',
          subtitle: '每日收到金句，提醒自己成長',
          accent: accent,
          delay: 900,
          onTap: _showScheduleReminderDialog,
        ),

        const SizedBox(height: 10),

        // ── Guidance: Share Card ──
        _GuidanceButton(
          emoji: '📸',
          title: 'Share 靚卡俾朋友',
          subtitle: '分享你嘅人格結果',
          accent: accent,
          delay: 950,
          onTap: _capturing ? null : _shareCard,
          trailing: _capturing
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : null,
        ),

        const SizedBox(height: 20),

        // ── Continue button ──
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('開始使用型得你'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
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

  // ─── Shadow Report ─────────────────────────────────────────────────

  void _openShadowReport() {
    final engine = ShadowReportEngine();
    final report = engine.generate(widget.mbti, widget.ennea);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShadowReportScreen(
          report: report,
          onComplete: () {},
        ),
      ),
    );
  }

  // ─── Reminder Dialog ───────────────────────────────────────────────

  void _showScheduleReminderDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) => _ReminderBottomSheet(
        accent: _mbtiVisuals[widget.mbti]?.temperament.accent ?? AppColors.purple,
        onSchedule: _scheduleReminder,
      ),
    );
  }

  Future<void> _scheduleReminder(String timeLabel, TimeOfDay time) async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await plugin.initialize(
        const InitializationSettings(android: androidSettings),
      );

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        '每日提醒',
        channelDescription: '每日金句同成長提醒',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      await plugin.show(
        0,
        '型得你 — 每日提醒',
        '係時候睇吓你嘅成長日記啦！',
        const NotificationDetails(android: androidDetails),
      );

      if (mounted) {
        Navigator.of(context).pop(); // close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 已設定每日 $timeLabel 提醒'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.sage,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('暫時未能設定提醒，請喺系統設定中開啟通知權限'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
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

// ─── Guidance Button ─────────────────────────────────────────────────

class _GuidanceButton extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final int delay;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _GuidanceButton({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.delay,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Emoji icon ──
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: accent.withValues(alpha: 0.5),
              ),
          ],
        ),
      ).animate().fadeIn(
            duration: 300.ms,
            delay: delay.ms,
          ).slideX(
            begin: 0.03,
            duration: 300.ms,
            delay: delay.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

// ─── Reminder Bottom Sheet ──────────────────────────────────────────

class _ReminderBottomSheet extends StatefulWidget {
  final Color accent;
  final void Function(String label, TimeOfDay time) onSchedule;
  const _ReminderBottomSheet({required this.accent, required this.onSchedule});

  @override
  State<_ReminderBottomSheet> createState() => _ReminderBottomSheetState();
}

class _ReminderBottomSheetState extends State<_ReminderBottomSheet> {
  final List<_ReminderOption> _options = [
    _ReminderOption('☀️ 朝早 (08:00)', const TimeOfDay(hour: 8, minute: 0)),
    _ReminderOption('🌤️ 中午 (12:00)', const TimeOfDay(hour: 12, minute: 0)),
    _ReminderOption('🌇 下晝 (18:00)', const TimeOfDay(hour: 18, minute: 0)),
    _ReminderOption('🌙 夜晚 (21:00)', const TimeOfDay(hour: 21, minute: 0)),
  ];

  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ──
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Title ──
          Text(
            '⏰ 設定每日提醒時間',
            style: GoogleFonts.notoSerifTc(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '揀一個時間，每日收到成長提示同金句',
            style: GoogleFonts.notoSansTc(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // ── Options ──
          ...List.generate(_options.length, (i) {
            final selected = _selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? widget.accent.withValues(alpha: 0.08)
                        : AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? widget.accent.withValues(alpha: 0.4)
                          : AppColors.border.withValues(alpha: 0.5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(_options[i].emojiLabel, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _options[i].displayLabel,
                          style: GoogleFonts.notoSansTc(
                            fontSize: 16,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? widget.accent : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (selected)
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: widget.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          // ── Confirm button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _selected != null
                  ? () => widget.onSchedule(
                        _options[_selected!].displayLabel,
                        _options[_selected!].time,
                      )
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                disabledBackgroundColor: AppColors.disabled,
                disabledForegroundColor: AppColors.disabledText,
                textStyle: GoogleFonts.notoSansTc(
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(_selected != null ? '確定設定' : '揀一個時間'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderOption {
  final String emojiLabel;
  final TimeOfDay time;
  String get displayLabel => emojiLabel.split(' ').last.trim();
  const _ReminderOption(this.emojiLabel, this.time);
}

// ─── Hero Visual Card (Redesigned) ──────────────────────────────────────

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
            accent.withValues(alpha: 0.85),
            Color.lerp(accent, Colors.white, 0.15)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Decorative: top-right large circle ──
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // ── Decorative: bottom-left medium circle ──
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // ── Decorative: dots pattern (top-left) ──
          Positioned(
            top: 20,
            left: 20,
            child: _DotsPattern(color: Colors.white.withValues(alpha: 0.08)),
          ),
          // ── Decorative: dots pattern (bottom-right) ──
          Positioned(
            bottom: 80,
            right: 20,
            child: _DotsPattern(color: Colors.white.withValues(alpha: 0.06)),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // ── Brand tag ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Typingself · 型得你',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Emoji in glass container ──
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── MBTI type ──
                Text(
                  mbti,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),

                // ── Archetype ──
                Text(
                  archetype,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Type badge row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BadgeChip(label: mbti, opacity: 0.2),
                    const SizedBox(width: 8),
                    _BadgeChip(label: ennea, opacity: 0.15),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Divider ──
                Container(
                  height: 1,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Personality name card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '你嘅人格稱號',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nameCanto,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerifTc(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Footer tagline ──
                Text(
                  '了解自己，贏返自己',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 1,
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

// ─── Small decorative dots pattern ───

class _DotsPattern extends StatelessWidget {
  final Color color;
  const _DotsPattern({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (__) => Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          )),
        ),
      )),
    );
  }
}

// ─── Badge chip ───

class _BadgeChip extends StatelessWidget {
  final String label;
  final double opacity;
  const _BadgeChip({required this.label, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSansTc(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
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

// ─── Chart Section reusable wrapper ──────────────────────────────────

class _ChartSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ChartBar> bars;
  final Color accent;
  final Color accentLight;
  final double chartHeight;

  const _ChartSection({
    required this.title,
    required this.subtitle,
    required this.bars,
    required this.accent,
    required this.accentLight,
    required this.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: GoogleFonts.notoSansTc(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(
                bars: bars,
                accent: accent,
                accentLight: accentLight,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 550.ms)
        .slideY(begin: 0.04, duration: 400.ms, delay: 550.ms, curve: Curves.easeOutCubic);
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

// ─── Helper ───────────────────────────────────────────────────────────

class _IndexedScore {
  final int type;
  final double score;
  const _IndexedScore({required this.type, required this.score});
}
