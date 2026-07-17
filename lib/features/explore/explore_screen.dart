// ═══════════════════════════════════════════════════════════════════════
// ExploreScreen — Edition 2 Redesign
// Gradient background (lavender→coral) · Frosted glass cards
// Noto Serif TC headings · Larger, more spacious layout
// Daebi palette · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../../core/analytics_service.dart';
import '../../core/celebration_overlay.dart';
import '../daily_quote/zodiac_service.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/decision_tree_engine.dart';

// ─── Reusable card style ───
BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
    );

class ExploreScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String? mbti;
  final String? ennea;
  final VoidCallback? onRetakeTest;
  const ExploreScreen({super.key, required this.accent, required this.accentBg, this.mbti, this.ennea, this.onRetakeTest});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _stage1Done = false;
  bool _stage2Done = false;
  bool _stage3Done = false;
  bool _stage4Done = false;
  bool _loaded = false;
  String? _zodiac;
  bool _analyticsLogged = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stage1Done = prefs.getBool('stage1_done') ?? (prefs.getBool('test_done') ?? false);
      _stage2Done = prefs.getBool('stage2_done') ?? (prefs.getBool('shadow_report_viewed') ?? false);
      _stage3Done = prefs.getBool('stage3_done') ?? false;
      _stage4Done = prefs.getBool('stage4_done') ?? false;
      _zodiac = prefs.getString('zodiac_sign');
      _loaded = true;
    });

    // Log app_open analytics once per session
    if (!_analyticsLogged) {
      _analyticsLogged = true;
      AnalyticsService.log(AnalyticsService.appOpen, properties: {
        'stage1_done': _stage1Done,
        'stage2_done': _stage2Done,
        'stage3_done': _stage3Done,
        'stage4_done': _stage4Done,
        'mbti': widget.mbti,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEBE0F5), // lavender mist
            Color(0xFFFCE8E0), // light coral / warm pink
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Header ──
            _ExploreHeader(
              accent: widget.accent,
              accentBg: widget.accentBg,
              stage1Done: _stage1Done,
              stage2Done: _stage2Done,
              stage3Done: _stage3Done,
              stage4Done: _stage4Done,
            ),

            const SizedBox(height: 16),

            // ── Retake Test — at top ──
            _RetakeCard(
              accent: widget.accent,
              onRetake: _retakeTest,
            ),

            const SizedBox(height: 22),

            // ── 😊 今日心情 — Mood Tracker ──
            _MoodSection(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 22),

            // ── 🌟 今日運程 — Horoscope ──
            _ZodiacMini(
              zodiac: _zodiac,
              dayOfYear: dayOfYear,
              accent: widget.accent,
              accentBg: widget.accentBg,
            ),

            const SizedBox(height: 22),

            // ── 📤 分享型得你俾朋友 CTA ──
            _ShareCTA(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 22),

            // ── 📖 每日人格洞察 ──
            _SectionHeader('💡 每日人格洞察', widget.accent),
            const SizedBox(height: 10),
            if (widget.mbti != null && widget.ennea != null)
              _PersonalityInsightCard(
                mbti: widget.mbti!,
                ennea: widget.ennea!,
                accent: widget.accent,
                accentBg: widget.accentBg,
              )
            else
              _NoTestCard(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 22),

            // ── Stage 1: MBTI + Enneagram ──
            _SectionHeader(
              _stage1Done ? 'Stage 1 — 已完成 ✅' : 'Stage 1 — MBTI + Enneagram',
              widget.accent,
              subtitle: _stage1Done ? '' : '未完成',
            ),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '🧠',
              title: 'MBTI + Enneagram 人格測試',
              subtitle: _stage1Done && widget.mbti != null && widget.ennea != null
                  ? '${widget.mbti} · ${widget.ennea}  — 了解你嘅思維模式同核心動機'
                  : '完成測試以解鎖個人化洞察',
              badge: _stage1Done ? '已完成 ✅' : '開始測試',
              badgeColor: _stage1Done ? const Color(0xFF8FA87A) : widget.accent,
              onTap: _stage1Done
                  ? () => _showSnack('你嘅結果：${widget.mbti} · ${widget.ennea}')
                  : _startTest,
            ),

            const SizedBox(height: 16),

            // ── Stage 2: Shadow Report ──
            _SectionHeader(
              _stage2Done ? 'Stage 2 — 已完成 ✅' : 'Stage 2 — 陰影報告',
              widget.accent,
              subtitle: _stage2Done ? '' : (_stage1Done ? '已解鎖 🔓' : '需要先完成 Stage 1'),
            ),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '🌑',
              title: 'Shadow Report — 陰影報告',
              subtitle: _stage2Done
                  ? '你嘅面具、陰影、防禦機制 — 已解鎖 ✅'
                  : '4 頁深度人格陰影分析 — 了解你壓抑咗嘅部分',
              badge: _stage2Done ? '已完成 ✅' : (_stage1Done ? '免費開啟 🔓' : '🔒 鎖住'),
              badgeColor: _stage2Done
                  ? const Color(0xFF8FA87A)
                  : (_stage1Done ? widget.accent : AppColors.disabledText),
              locked: !_stage1Done,
              onTap: _stage2Done
                  ? () => _showSnack('Shadow Report 已睇過！')
                  : _stage1Done
                      ? () => _showSnack('去 Profile 頁睇 Shadow Report')
                      : () => _showSnack('需要先完成 Stage 1 嘅人格測試先'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '📊',
              title: '心靈健康 Quick Check',
              subtitle: '4 條問題了解你近一星期嘅心理狀態',
              badge: _stage1Done ? '免費 🆓' : '🔒 鎖住',
              badgeColor: _stage1Done ? widget.accent : AppColors.disabledText,
              locked: !_stage1Done,
              onTap: _stage1Done
                  ? () => _showSnack('心靈健康 Quick Check：即將推出')
                  : () => _showSnack('需要先完成 Stage 1'),
            ),

            const SizedBox(height: 12),

            // ── 快速反思卡 ──
            _ContentCard(
              icon: '💭',
              title: '每日三分鐘反思',
              subtitle: '一條問題引導你回顧今日嘅感受同覺察',
              badge: _stage1Done ? '免費 🆓' : '🔒 鎖住',
              badgeColor: _stage1Done ? widget.accent : AppColors.disabledText,
              locked: !_stage1Done,
              onTap: _stage1Done
                  ? () => _showSnack('每日反思：記低你嘅想法')
                  : () => _showSnack('需要先完成 Stage 1'),
            ),

            const SizedBox(height: 20),

            // ── Stage 3: Growth Plan ──
            _SectionHeader(
              _stage3Done ? 'Stage 3 — 已完成 ✅' : 'Stage 3 — 成長計劃',
              widget.accent,
              subtitle: _stage3Done
                  ? ''
                  : (_stage2Done ? '已解鎖 🔓' : '需要先完成 Stage 2'),
            ),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '🌱',
              title: 'Inferior Function 成長練習',
              subtitle: '每日 1 分鐘針對你嘅 inferior function 練習 + 進度追蹤',
              badge: _stage2Done ? (_stage3Done ? '已完成 ✅' : '免費開啟 🔓') : '🔒 鎖住',
              badgeColor: _stage3Done
                  ? const Color(0xFF8FA87A)
                  : (_stage2Done ? widget.accent : AppColors.disabledText),
              locked: !_stage2Done,
              onTap: _stage2Done
                  ? () => _showSnack('去成長練習頁開始練習')
                  : () => _showSnack('需要先完成 Stage 2 嘅 Shadow Report'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '✍️',
              title: 'S.O.A.R. 自我觀察日記',
              subtitle: '5 分鐘 guided check-in · 感官·觀察·對齊·反思',
              badge: _stage2Done ? '免費開啟 🔓' : '🔒 鎖住',
              badgeColor: _stage2Done ? widget.accent : AppColors.disabledText,
              locked: !_stage2Done,
              onTap: _stage2Done
                  ? () => _showSnack('S.O.A.R. 日記：即將推出')
                  : () => _showSnack('需要先完成 Stage 2'),
            ),

            const SizedBox(height: 20),

            // ── Stage 4: Integration ──
            _SectionHeader(
              _stage4Done ? 'Stage 4 — 已完成 ✅' : 'Stage 4 — 整合報告',
              widget.accent,
              subtitle: _stage4Done
                  ? ''
                  : (_stage3Done ? '已解鎖 🔓' : '需要先完成 Stage 3'),
            ),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '💎',
              title: 'Self-Integration 報告',
              subtitle: '完整認知功能平衡分析 + 4 階段進度 + 潛意識洞察',
              badge: _stage3Done ? (_stage4Done ? '已完成 ✅' : '免費開啟 🔓') : '🔒 鎖住',
              badgeColor: _stage4Done
                  ? const Color(0xFF8FA87A)
                  : (_stage3Done ? widget.accent : AppColors.disabledText),
              locked: !_stage3Done,
              onTap: _stage3Done
                  ? () => _showSnack(_stage4Done ? '整合報告已睇過！' : '整合報告：即將推出')
                  : () => _showSnack('需要先完成 Stage 3 嘅成長練習'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '📈',
              title: '季度趨勢 Dashboard',
              subtitle: '心情趨勢 · 成長進度 · 功能使用分佈 — 圖表化',
              badge: _stage3Done ? '免費開啟 🔓' : '🔒 鎖住',
              badgeColor: _stage3Done ? widget.accent : AppColors.disabledText,
              locked: !_stage3Done,
              onTap: _stage3Done
                  ? () => _showSnack('季度趨勢 Dashboard：即將推出')
                  : () => _showSnack('需要先完成 Stage 3'),
            ),

            const SizedBox(height: 24),

            // ── Bottom share CTA (repeated for visibility) ──
            _ShareStrip(accent: widget.accent),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _startTest() {
    AnalyticsService.log(AnalyticsService.testStarted);
    if (widget.onRetakeTest != null) {
      widget.onRetakeTest!();
    } else {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssessmentIntroScreen(
            engine: DecisionTreeEngine(questionCount: 20),
            onComplete: (mbti, ennea) {},
          ),
        ),
      );
    }
  }

  Future<void> _retakeTest() async {
    // Clear saved results
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_done', false);
    await prefs.setBool('stage1_done', false);
    await prefs.remove('mbti');
    await prefs.remove('ennea');
    await prefs.remove('selected_tagline');
    await prefs.remove('mbti_confidence');
    await prefs.remove('ennea_confidence');
    await prefs.remove('mbti_verified');
    await prefs.remove('ennea_verified');
    await prefs.remove('total_questions');
    await prefs.remove('mbti_result');
    await prefs.remove('ennea_result');

    AnalyticsService.log(AnalyticsService.testStarted);

    if (widget.onRetakeTest != null) {
      widget.onRetakeTest!();
      return;
    }

    // Fallback: navigate directly to intro screen
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AssessmentIntroScreen(
          engine: DecisionTreeEngine(questionCount: 20),
          onComplete: (mbti, ennea) {},
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.notoSansTc(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── SHARE CTA ──
class _ShareCTA extends StatelessWidget {
  final Color accent, accentBg;
  const _ShareCTA({required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '分享型得你俾朋友',
      button: true,
      child: GestureDetector(
        onTap: () {
          Share.share(
            '我喺「型得你」了解緊自己嘅 MBTI 同 Enneagram 🧠\\n\\n'
            '一步步由人格到整合，好有趣！\\n'
            '你都嚟測下啦 👇\\n'
            'https://xingdeni.app',
            subject: '型得你 — 認識自己嘅第一步',
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text('📤', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('分享型得你俾朋友',
                      style: GoogleFonts.notoSerifTc(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('叫 Friend 都測下 MBTI + Enneagram，一齊了解自己',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom share strip ──
class _ShareStrip extends StatelessWidget {
  final Color accent;
  const _ShareStrip({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '分享型得你俾朋友',
      button: true,
      child: GestureDetector(
        onTap: () {
          Share.share(
            '我喺「型得你」了解緊自己 🧠 MBTI + Enneagram + 陰影報告\\n\\n'
            '你都嚟玩下 👇\\n'
            'https://xingdeni.app',
            subject: '型得你 — 人格成長 App',
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📤', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('分享型得你俾朋友',
                style: GoogleFonts.notoSansTc(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── RETAKE TEST CARD ───
class _RetakeCard extends StatelessWidget {
  final Color accent;
  final VoidCallback onRetake;

  const _RetakeCard({required this.accent, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '重新測試',
      button: true,
      child: GestureDetector(
        onTap: onRetake,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🔄', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('重新測試',
                      style: GoogleFonts.notoSerifTc(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('清空現有結果，揀新版本再測一次',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('重測',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ──
class _ExploreHeader extends StatelessWidget {
  final Color accent, accentBg;
  final bool stage1Done, stage2Done, stage3Done, stage4Done;
  const _ExploreHeader({
    required this.accent,
    required this.accentBg,
    required this.stage1Done,
    required this.stage2Done,
    required this.stage3Done,
    required this.stage4Done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('🗺️', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Text('自我認識地圖', style: GoogleFonts.notoSerifTc(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('由 MBTI 到整合報告，一步一步深入了解自己。',
            style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeaderStage(0, '🧠', 'Stage 1', stage1Done, accent),
              const SizedBox(width: 8),
              _HeaderStage(1, '🌑', 'Stage 2', stage2Done, accent),
              const SizedBox(width: 8),
              _HeaderStage(2, '🌱', 'Stage 3', stage3Done, accent),
              const SizedBox(width: 8),
              _HeaderStage(3, '💎', 'Stage 4', stage4Done, accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStage extends StatelessWidget {
  final int index;
  final String emoji, label;
  final bool active;
  final Color accent;
  const _HeaderStage(this.index, this.emoji, this.label, this.active, this.accent);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: active ? '$label — 已解鎖' : '$label — 未解鎖',
      selected: active,
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8FA87A).withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active ? Border.all(color: const Color(0xFF8FA87A).withValues(alpha: 0.3)) : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 18, color: active ? Colors.black87 : AppColors.textMuted)),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? const Color(0xFF8FA87A) : AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  final String text;
  final Color accent;
  final String? subtitle;
  const _SectionHeader(this.text, this.accent, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(text, style: GoogleFonts.notoSerifTc(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
        if (subtitle != null && subtitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(subtitle!, style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
          ),
      ],
    );
  }
}

// ── Content Card ──
class _ContentCard extends StatelessWidget {
  final String icon, title, subtitle, badge;
  final Color badgeColor;
  final bool locked;
  final VoidCallback onTap;

  const _ContentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    this.locked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = locked ? AppColors.textMuted : AppColors.textPrimary;
    final textSecondary = locked ? AppColors.textMuted : AppColors.textSecondary;
    final cardOpacity = locked ? 0.75 : 0.88;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: cardOpacity),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: locked
                ? AppColors.border.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: locked ? 0.03 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: locked
                    ? AppColors.background.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: locked
                      ? AppColors.border.withValues(alpha: 0.2)
                      : AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(locked ? '🔒' : icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: GoogleFonts.notoSerifTc(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood Tracker — moved from home screen
// ─────────────────────────────────────────────────────────────────────────────
class _MoodSection extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  const _MoodSection({required this.accent, required this.accentBg});
  @override
  State<_MoodSection> createState() => _MoodSectionState();
}

class _MoodSectionState extends State<_MoodSection> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final labels = ['☀️ 好好', '🙂 幾好', '😐 普通', '😔 麻麻', '😤 好燥'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header inside card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.accentBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: widget.accent.withValues(alpha: 0.15)),
                ),
                child: Text('😊 今日心情', style: GoogleFonts.notoSansTc(
                  fontSize: 14, fontWeight: FontWeight.w700, color: widget.accent,
                  letterSpacing: 0.3,
                )),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // ── Mood dots row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final isSelected = _selected == i;
              return Semantics(
                label: labels[i],
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? widget.accent : widget.accent.withValues(alpha: 0.08),
                      border: Border.all(
                        color: isSelected
                            ? widget.accent
                            : widget.accent.withValues(alpha: 0.15),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: widget.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Center(
                      child: isSelected
                          ? const Icon(Icons.favorite, size: 20, color: Colors.white)
                          : Icon(Icons.favorite_border, size: 18, color: widget.accent.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          // ── Mood labels row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) => Text(
              labels[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: _selected == i ? FontWeight.w700 : FontWeight.w500,
                color: _selected == i ? widget.accent : AppColors.textMuted,
              ),
            )),
          ),
          const SizedBox(height: 12),
          // ── Selected mood feedback ──
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selected != null ? widget.accent.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _selected != null ? _moodLabel(_selected!) : '㩒個圓點記錄今日心情',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _selected != null ? widget.accent : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moodLabel(int i) {
    switch (i) {
      case 0: return '今日心情好好 ☀️';
      case 1: return '今日心情幾好 🙃';
      case 2: return '今日心情普通 😐';
      case 3: return '今日心情麻麻 😔';
      case 4: return '今日心情好燥 😤';
      default: return '今日心情：—';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zodiac / Horoscope — moved from home screen
// ─────────────────────────────────────────────────────────────────────────────
class _ZodiacMini extends StatelessWidget {
  final String? zodiac;
  final int dayOfYear;
  final Color accent, accentBg;
  const _ZodiacMini({required this.zodiac, required this.dayOfYear, required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    final sign = zodiac ?? '天蠍';
    final emoji = ZodiacService.signEmoji[sign] ?? '♏';
    final horoscope = ZodiacService.dailyHoroscope(sign, dayOfYear);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Text('🌟 今日運程', style: GoogleFonts.notoSansTc(
                  fontSize: 14, fontWeight: FontWeight.w700, color: accent,
                  letterSpacing: 0.3,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sign row
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Text(sign, style: GoogleFonts.notoSansTc(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('設定星座', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horoscope text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.08)),
            ),
            child: Text(horoscope, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Personality Insight Card — new content card
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalityInsightCard extends StatelessWidget {
  final String mbti, ennea;
  final Color accent, accentBg;
  const _PersonalityInsightCard({
    required this.mbti,
    required this.ennea,
    required this.accent,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MBTI + Ennea combo badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('$mbti · $ennea',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Insight text
          Text(_insightFor(mbti, ennea),
            style: GoogleFonts.notoSerifTc(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          // Tag row
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (_tagsFor(mbti)).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.12)),
              ),
              child: Text(tag,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: accent),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),
          // Share this insight
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Share.share(
                  '【今日人格洞察】\n\n'
                  '${_insightFor(mbti, ennea)}\n\n'
                  '— 型得你 @typingself\n'
                  'https://xingdeni.app',
                  subject: '型得你 — 今日人格洞察',
                );
              },
              icon: const Icon(Icons.share, size: 15),
              label: Text('分享呢個 insight', style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _insightFor(String mbti, String ennea) {
    final insights = <String, String>{
      'ENFJ': '你天生係一個領導者，擅長激勵同埋理解身邊嘅人。你最需要記住嘅係：都要照顧好自己。',
      'INFJ': '你嘅直覺同同理心係你最強大嘅武器。你見到嘅嘢比表面多好多，相信你嘅判斷。',
      'INTJ': '你嘅思維清晰得可怕，策略係你本能。唔好因為其他人睇唔到你嘅視野而懷疑自己。',
      'ENTJ': '效率係你嘅超能力。你見到問題就會想解決，見到目標就會想去到。小心：唔好人人都覺得你太堅持。',
      'ENFP': '你係創意嘅靈魂，自由嘅心。你最大嘅天賦係令身邊嘅人覺得乜都有可能。',
      'INFP': '你嘅內心世界豐富而溫柔。你感受到嘅嘢係你力量嘅來源，唔好收埋佢。',
      'ENTP': '你鍾意挑戰權威，打破框架。你諗嘢快過人，但記住：唔係所有問題都需要反駁。',
      'INTP': '你係一個分析機器，乜嘢都可以拆解再重組。你嘅好奇心係冇底嘅，保持落去。',
      'ESFJ': '你係群體嘅 glue，所有人嘅 connect。你付出咁多，記得留返啲愛俾自己。',
      'ISFJ': '你係最可靠嘅守護者。你記得每個人嘅需要，但你嘅需要都同樣重要。',
      'ESTJ': '你話得到就做得到，執行力滿分。你存在嘅本身就令成個系統更穩定。',
      'ISTJ': '你係每個人都想有嘅隊友。準時、可靠、有原則 — 呢啲全部係你嘅超能力。',
      'ESFP': '你係 party 嘅靈魂，氣氛嘅製造者。你令世界變得更有趣。',
      'ISFP': '你嘅美感同敏感度係禮物。你用自己嘅方式感受世界，已經足夠。',
      'ESTP': '你係行動派，見到機會就會扑。你嘅勇敢令身邊嘅人佩服。',
      'ISTP': '你係 practical 嘅天才。任何嘢到你手上你都搞得掂。低調但強大。',
    };
    return insights[mbti] ?? '你係獨一無二嘅組合。繼續探索自己嘅每一面。';
  }

  List<String> _tagsFor(String mbti) {
    final tags = <String, List<String>>{
      'ENFJ': ['領導者', '同理心', '熱情'],
      'INFJ': ['直覺', '深度', '理想主義'],
      'INTJ': ['戰略', '獨立', '決斷'],
      'ENTJ': ['指揮', '效率', '目標為本'],
      'ENFP': ['創意', '自由', '可能性'],
      'INFP': ['理想', '同理心', '創造力'],
      'ENTP': ['辯論', '創新', '靈活'],
      'INTP': ['分析', '邏輯', '好奇心'],
      'ESFJ': ['社交', '關懷', '組織'],
      'ISFJ': ['守護', '忠誠', '細心'],
      'ESTJ': ['執行', '秩序', '可靠'],
      'ISTJ': ['可靠', '責任', '精準'],
      'ESFP': ['表演', '活力', '即興'],
      'ISFP': ['藝術', '敏感', '實用'],
      'ESTP': ['行動', '冒險', '說服力'],
      'ISTP': ['實用', '冷靜', '技術'],
    };
    return tags[mbti] ?? ['探索者'];
  }
}

// ── No Test Card ──
class _NoTestCard extends StatelessWidget {
  final Color accent, accentBg;
  const _NoTestCard({required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: const Center(child: Text('🧪', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 10),
              Text('未完成測驗', style: GoogleFonts.notoSansTc(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: accent,
              )),
            ],
          ),
          const SizedBox(height: 14),
          Text('你未完成測驗', style: GoogleFonts.notoSerifTc(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, height: 1.2,
          )),
          const SizedBox(height: 8),
          Text('完成測試後，呢度會顯示你嘅人格洞察同標籤。', style: GoogleFonts.notoSansTc(
            fontSize: 14, fontWeight: FontWeight.w400,
            color: AppColors.textSecondary, height: 1.5,
          )),
        ],
      ),
    );
  }
}
