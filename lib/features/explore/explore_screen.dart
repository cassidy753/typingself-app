// ═══════════════════════════════════════════════════════════════════════
// ExploreScreen — Edition 2 Redesign
// Gradient background (lavender→coral) · Frosted glass cards
// Noto Serif TC headings · Larger, more spacious layout
// Daebi palette · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/decision_tree_engine.dart';

class ExploreScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String mbti;
  final String ennea;
  final VoidCallback? onRetakeTest;
  const ExploreScreen({super.key, required this.accent, required this.accentBg, required this.mbti, required this.ennea, this.onRetakeTest});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _shadowDone = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shadowDone = prefs.getBool('shadow_report_viewed') ?? false;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

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
            _ExploreHeader(accent: widget.accent, accentBg: widget.accentBg),

            const SizedBox(height: 20),

            // ── Stage 1: MBTI + Enneagram ──
            _SectionHeader('已解鎖 ✅', widget.accent),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '🧠',
              title: 'MBTI + Enneagram 人格測試',
              subtitle: '${widget.mbti} · ${widget.ennea}  — 了解你嘅思維模式同核心動機',
              badge: '已解鎖',
              badgeColor: const Color(0xFF8FA87A),
              onTap: () => _showSnack('重新測試：清空記錄後可以再做一次'),
            ),

            const SizedBox(height: 16),

            // ── Stage 2: Shadow Report ──
            _SectionHeader('免費 🆓', widget.accent),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '🌑',
              title: 'Shadow Report — 陰影報告',
              subtitle: _shadowDone
                  ? '你嘅面具、陰影、防禦機制 — 已解鎖 ✅'
                  : '4 頁深度人格陰影分析 — 了解你壓抑咗嘅部分',
              badge: _shadowDone ? '已完成' : '免費開啟',
              badgeColor: _shadowDone ? const Color(0xFF8FA87A) : widget.accent,
              onTap: () => _showSnack(_shadowDone ? 'Shadow Report 已睇過，可以去首頁重溫' : 'Shadow Report：按「繼續探索」後可睇'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '📊',
              title: '心靈健康 Quick Check',
              subtitle: '4 條問題了解你近一星期嘅心理狀態',
              badge: '免費',
              badgeColor: widget.accent,
              onTap: () => _showSnack('心靈健康 Quick Check：即將推出'),
            ),

            const SizedBox(height: 20),

            // ── Stage 3: Growth Plan ──
            _SectionHeader('Stage 3 — 成長計劃', widget.accent, subtitle: '需要進一步解鎖'),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '🌱',
              title: 'Inferior Function 成長練習',
              subtitle: '每日 1 分鐘針對你嘅 inferior function 練習 + 進度追蹤',
              badge: '需要進一步解鎖',
              badgeColor: AppColors.disabledText,
              locked: true,
              onTap: () => _showSnack('Stage 3 成長計劃需要進一步解鎖'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '✍️',
              title: 'S.O.A.R. 自我觀察日記',
              subtitle: '5 分鐘 guided check-in · 感官·觀察·對齊·反思',
              badge: '需要進一步解鎖',
              badgeColor: AppColors.disabledText,
              locked: true,
              onTap: () => _showSnack('S.O.A.R. 日記需要進一步解鎖'),
            ),

            const SizedBox(height: 20),

            // ── Stage 4: Integration ──
            _SectionHeader('Stage 4 — 整合報告', widget.accent, subtitle: '需要進一步解鎖'),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '💎',
              title: 'Self-Integration 報告',
              subtitle: '完整認知功能平衡分析 + 4 階段進度 + 潛意識洞察',
              badge: '需要進一步解鎖',
              badgeColor: AppColors.disabledText,
              locked: true,
              onTap: () => _showSnack('Stage 4 整合報告需要進一步解鎖'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '📈',
              title: '季度趨勢 Dashboard',
              subtitle: '心情趨勢 · 成長進度 · 功能使用分佈 — 圖表化',
              badge: '需要進一步解鎖',
              badgeColor: AppColors.disabledText,
              locked: true,
              onTap: () => _showSnack('季度趨勢需要進一步解鎖'),
            ),

            const SizedBox(height: 20),

            // ── Coming Soon ──
            _SectionHeader('即將推出 🔮', widget.accent),
            const SizedBox(height: 10),
            _ContentCard(
              icon: '♈',
              title: '星座深度分析',
              subtitle: '個人星盤 · 行星解讀 · 上升星座',
              badge: '即將',
              badgeColor: AppColors.textMuted,
              locked: true,
              onTap: () => _showSnack('星座深度分析：敬請期待'),
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: '🏛️',
              title: '八字基礎',
              subtitle: '四柱八字 · 十神分析 · 大運流年',
              badge: '即將',
              badgeColor: AppColors.textMuted,
              locked: true,
              onTap: () => _showSnack('八字基礎：敬請期待'),
            ),

            const SizedBox(height: 24),

            // ── Retake Test Button ──
            _RetakeCard(
              accent: widget.accent,
              onRetake: _retakeTest,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _retakeTest() async {
    // Clear saved results
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_done', false);
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

// ─── RETAKE TEST CARD ───
class _RetakeCard extends StatelessWidget {
  final Color accent;
  final VoidCallback onRetake;

  const _RetakeCard({required this.accent, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                      fontSize: 13,
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
    );
  }
}

// ── Header ──
class _ExploreHeader extends StatelessWidget {
  final Color accent, accentBg;
  const _ExploreHeader({required this.accent, required this.accentBg});

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
          Text('由 MBTI 到 八字，由陰影到整合 — 一步一步深入了解自己。',
            style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeaderStage(0, '🧠', 'Stage 1', true, accent),
              const SizedBox(width: 8),
              _HeaderStage(1, '🌑', 'Stage 2', false, accent),
              const SizedBox(width: 8),
              _HeaderStage(2, '🌱', 'Stage 3', false, accent),
              const SizedBox(width: 8),
              _HeaderStage(3, '💎', 'Stage 4', false, accent),
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
    return Expanded(
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
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? const Color(0xFF8FA87A) : AppColors.textMuted)),
          ],
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
        if (subtitle != null)
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
                      fontSize: 13,
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
                    fontSize: 12,
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
