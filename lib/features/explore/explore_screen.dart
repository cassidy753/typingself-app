import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

class ExploreScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String mbti;
  final String ennea;
  const ExploreScreen({super.key, required this.accent, required this.accentBg, required this.mbti, required this.ennea});

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Header ──
          _ExploreHeader(accent: widget.accent, accentBg: widget.accentBg),

          const SizedBox(height: 16),

          // ── Stage 1: MBTI + Enneagram ──
          _SectionHeader('已解鎖 ✅', widget.accent),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '🧠',
            title: 'MBTI + Enneagram 人格測試',
            subtitle: '${widget.mbti} · ${widget.ennea}  — 了解你嘅思維模式同核心動機',
            badge: '已解鎖',
            badgeColor: const Color(0xFF8FA87A),
            onTap: () => _showSnack('重新測試：清空記錄後可以再做一次'),
          ),

          const SizedBox(height: 14),

          // ── Stage 2: Shadow Report ──
          _SectionHeader('免費 🆓', widget.accent),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          _ContentCard(
            icon: '📊',
            title: '心靈健康 Quick Check',
            subtitle: '4 條問題了解你近一星期嘅心理狀態',
            badge: '免費',
            badgeColor: widget.accent,
            onTap: () => _showSnack('心靈健康 Quick Check：即將推出'),
          ),

          const SizedBox(height: 14),

          // ── Stage 3: Growth Plan ──
          _SectionHeader('Stage 3 — 成長計劃', widget.accent, subtitle: 'HK\$15 一次解鎖'),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '🌱',
            title: 'Inferior Function 成長練習',
            subtitle: '每日 1 分鐘針對你嘅 inferior function 練習 + 進度追蹤',
            badge: '\$15',
            badgeColor: const Color(0xFFE0785A),
            locked: true,
            onTap: () => _showSnack('Stage 3：HK\$15 解鎖完整成長計劃'),
          ),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '✍️',
            title: 'S.O.A.R. 自我觀察日記',
            subtitle: '5 分鐘 guided check-in · 感官·觀察·對齊·反思',
            badge: '\$15',
            badgeColor: const Color(0xFFE0785A),
            locked: true,
            onTap: () => _showSnack('S.O.A.R. 日記包含喺 Stage 3 成長計劃'),
          ),

          const SizedBox(height: 14),

          // ── Stage 4: Integration ──
          _SectionHeader('Stage 4 — 整合報告', widget.accent, subtitle: 'HK\$28/月 或 HK\$168/年'),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '💎',
            title: 'Self-Integration 報告',
            subtitle: '完整認知功能平衡分析 + 4 階段進度 + 潛意識洞察',
            badge: '\$28/月',
            badgeColor: const Color(0xFF9B72AA),
            locked: true,
            onTap: () => _showSnack('Stage 4：HK\$28/月 或 HK\$168/年'),
          ),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '📈',
            title: '季度趨勢 Dashboard',
            subtitle: '心情趨勢 · 成長進度 · 功能使用分佈 — 圖表化',
            badge: 'Premium',
            badgeColor: const Color(0xFF9B72AA),
            locked: true,
            onTap: () => _showSnack('季度趨勢包含喺 Stage 4'),
          ),

          const SizedBox(height: 14),

          // ── Coming Soon ──
          _SectionHeader('即將推出 🔮', widget.accent),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '♈',
            title: '星座深度分析',
            subtitle: '個人星盤 · 行星解讀 · 上升星座',
            badge: '即將',
            badgeColor: AppColors.textMuted,
            locked: true,
            onTap: () => _showSnack('星座深度分析：敬請期待'),
          ),
          const SizedBox(height: 8),
          _ContentCard(
            icon: '🏛️',
            title: '八字基礎',
            subtitle: '四柱八字 · 十神分析 · 大運流年',
            badge: '即將',
            badgeColor: AppColors.textMuted,
            locked: true,
            onTap: () => _showSnack('八字基礎：敬請期待'),
          ),

          const SizedBox(height: 32),
        ],
      ),
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

// ── Header ──
class _ExploreHeader extends StatelessWidget {
  final Color accent, accentBg;
  const _ExploreHeader({required this.accent, required this.accentBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('🗺️', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Text('自我認識地圖', style: GoogleFonts.notoSerifTc(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Text('由 MBTI 到 八字，由陰影到整合 — 一步一步深入了解自己。',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 14),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF8FA87A).withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active ? Border.all(color: const Color(0xFF8FA87A).withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 16, color: active ? Colors.black87 : AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: active ? const Color(0xFF8FA87A) : AppColors.textMuted)),
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
        Text(text, style: GoogleFonts.notoSerifTc(fontSize: 15, fontWeight: FontWeight.w700, color: accent)),
        if (subtitle != null)
          Text(subtitle!, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: locked ? AppColors.border.withValues(alpha: 0.5) : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(locked ? '🔒' : icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: locked ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: TextStyle(fontSize: 11, color: locked ? AppColors.textMuted : AppColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor)),
            ),
          ],
        ),
      ),
    );
  }
}
