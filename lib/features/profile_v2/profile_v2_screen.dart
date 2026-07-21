// ═══════════════════════════════════════════════════════════════════════
// ProfileV2Screen — 👤 我 (Tab 4) — Edition 4
// MBTI type card + 閱讀統計Dashboard + 設定
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/settings_service.dart';
import '../reading/reading_content.dart';
import '../settings/settings_screen.dart';

class ProfileV2Screen extends StatefulWidget {
  final String? mbti;
  final String? ennea;
  final VoidCallback? onRetakeTest;
  final VoidCallback? onThemeChanged;
  const ProfileV2Screen({
    super.key,
    this.mbti,
    this.ennea,
    this.onRetakeTest,
    this.onThemeChanged,
  });

  @override
  State<ProfileV2Screen> createState() => _ProfileV2ScreenState();
}

class _ProfileV2ScreenState extends State<ProfileV2Screen> {
  final SettingsService _settings = SettingsService();
  bool _initialized = false;

  static const _ageLabels = ['18-25', '26-35', '36-45', '46-55', '55+'];
  static const _ageValues = ['18-25', '26-35', '36-45', '46-55', '55+'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ReadingContentProvider.initialize();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Center(child: CircularProgressIndicator());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedIds = _settings.getCompletedBookIds();
    final allBooks = ReadingContentProvider.allBooks;

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text('我',
              style: GoogleFonts.notoSerifTc(
                fontSize: 24, fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            const SizedBox(height: 16),

            // ── Type Card ──
            _TypeCard(
              mbti: widget.mbti ?? '未知',
              ennea: widget.ennea ?? '未知',
              onRetake: widget.onRetakeTest,
            ),
            const SizedBox(height: 20),

            // ── Reading Stats Dashboard ──
            _StatsDashboard(
              comboCount: completedIds.length,
              readingMinutes: _settings.totalReadingMinutes,
              streakDays: _settings.streakDays,
              totalBooks: allBooks.length,
              completedBooks: completedIds.length,
            ),
            const SizedBox(height: 24),

            // ── Settings Section ──
            Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accentEarth.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.settings_outlined, size: 14, color: AppColors.accentEarth),
                ),
                const SizedBox(width: 8),
                Text('設定',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),

            // Dark mode toggle
            _SettingsTile(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              iconColor: isDark ? AppColors.accentDusty : AppColors.accentGold,
              title: '深色模式',
              trailing: Switch.adaptive(
                value: _settings.darkMode,
                activeColor: AppColors.accentDusty,
                onChanged: (v) {
                  _settings.darkMode = v;
                  widget.onThemeChanged?.call();
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 8),

            // Language style toggle
            _SettingsTile(
              icon: Icons.translate_rounded,
              iconColor: AppColors.accentSage,
              title: '語言風格',
              subtitle: _settings.isNaturalCanto ? '自然粵語' : '書面粵語',
              trailing: Switch.adaptive(
                value: _settings.isNaturalCanto,
                activeColor: AppColors.accentSage,
                onChanged: (v) {
                  _settings.languageStyle = v ? LanguageStyle.naturalCanto : LanguageStyle.writtenCanto;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 8),

            // Font size
            _FontSizeTile(
              currentSize: _settings.fontSize,
              isDark: isDark,
              onChanged: (v) {
                _settings.fontSize = v;
                setState(() {});
              },
            ),
            const SizedBox(height: 8),

            // Age filter
            _AgeSelector(
              currentValue: _settings.ageFilter,
              labels: _ageLabels,
              values: _ageValues,
              onChanged: (v) {
                _settings.ageFilter = v;
                setState(() {});
              },
            ),
            const SizedBox(height: 24),

            // ── Actions ──
            Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accentCoral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.more_horiz_rounded, size: 14, color: AppColors.accentCoral),
                ),
                const SizedBox(width: 8),
                Text('更多',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),

            _ActionTile(
              icon: Icons.replay_rounded,
              iconColor: AppColors.accentCoral,
              title: '重新做人格測試',
              subtitle: '清除結果，重新開始',
              onTap: widget.onRetakeTest,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.tune_rounded,
              iconColor: AppColors.accentDusty,
              title: '進階設定',
              subtitle: '星座・同意・資料管理',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      accent: AppColors.accentDusty,
                      accentBg: AppColors.accentDusty.withValues(alpha: 0.12),
                      mbti: widget.mbti,
                      ennea: widget.ennea,
                      onRetakeTest: widget.onRetakeTest,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.assignment_rounded,
              iconColor: AppColors.accentEarth,
              title: '完整人格報告',
              subtitle: 'MBTI 九型深度分析',
              onTap: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Type Card ───
class _TypeCard extends StatelessWidget {
  final String mbti, ennea;
  final VoidCallback? onRetake;

  const _TypeCard({
    required this.mbti,
    required this.ennea,
    this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = mbti != '未知';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentEarth,
            AppColors.accentEarth.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentEarth.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(
              isCompleted ? _getEmoji(mbti) : '🧠',
              style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 10),
          Text(
            isCompleted ? _getName(mbti) : '未進行測試',
            style: GoogleFonts.notoSerifTc(
              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$mbti · $ennea',
                style: GoogleFonts.notoSansTc(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          const SizedBox(height: 10),
          if (onRetake != null)
            GestureDetector(
              onTap: onRetake,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('重新測試',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
              ),
            ),
        ],
      ),
    );
  }

  String _getEmoji(String t) {
    switch (t) {
      case 'ENFJ': return '🌟'; case 'INFJ': return '🌙'; case 'INTJ': return '♟️'; case 'ENTJ': return '👑';
      case 'ENFP': return '🦋'; case 'INFP': return '🌈'; case 'ENTP': return '💡'; case 'INTP': return '🔍';
      case 'ESFJ': return '🤝'; case 'ISFJ': return '🛡️'; case 'ESTJ': return '📋'; case 'ISTJ': return '⚖️';
      case 'ESFP': return '🎉'; case 'ISFP': return '🎨'; case 'ESTP': return '🚀'; case 'ISTP': return '🔧';
      default: return '🧠';
    }
  }

  String _getName(String t) {
    switch (t) {
      case 'ENFJ': return '高級KAM L'; case 'INFJ': return '靈性導師'; case 'INTJ': return '戰略家'; case 'ENTJ': return '指揮官';
      case 'ENFP': return '快樂小狗'; case 'INFP': return '夢想家'; case 'ENTP': return '挑戰者'; case 'INTP': return '思考者';
      case 'ESFJ': return '社群心臟'; case 'ISFJ': return '守護者'; case 'ESTJ': return '執行者'; case 'ISTJ': return '可靠支柱';
      case 'ESFP': return '派對靈魂'; case 'ISFP': return '藝術家'; case 'ESTP': return '冒險家'; case 'ISTP': return '工匠';
      default: return '探索者';
    }
  }
}

// ─── Stats Dashboard ───
class _StatsDashboard extends StatelessWidget {
  final int comboCount, readingMinutes, streakDays, totalBooks, completedBooks;

  const _StatsDashboard({
    required this.comboCount,
    required this.readingMinutes,
    required this.streakDays,
    required this.totalBooks,
    required this.completedBooks,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = (readingMinutes / 60).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: AppColors.accentEarth.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 14, color: AppColors.accentEarth),
              ),
              const SizedBox(width: 8),
              Text('閱讀統計',
                style: GoogleFonts.notoSerifTc(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatTile(
                icon: Icons.grid_view_rounded,
                value: '$comboCount',
                label: '已探索Combo',
                accent: AppColors.accentDusty,
              )),
              Expanded(child: _StatTile(
                icon: Icons.timer_outlined,
                value: '${hours}h',
                label: '閱讀時數',
                accent: AppColors.accentCoral,
              )),
              Expanded(child: _StatTile(
                icon: Icons.local_fire_department_rounded,
                value: '$streakDays',
                label: '連續日數',
                accent: AppColors.accentGold,
              )),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalBooks > 0 ? completedBooks / totalBooks : 0,
              minHeight: 8,
              backgroundColor: AppColors.accentEarth.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentEarth),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('書本完成度',
                style: GoogleFonts.notoSansTc(fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              Text('$completedBooks/$totalBooks',
                style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.accentEarth)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color accent;
  const _StatTile({required this.icon, required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: accent),
        const SizedBox(height: 4),
        Text(value,
          style: GoogleFonts.notoSerifTc(
            fontSize: 24, fontWeight: FontWeight.w900, color: accent)),
        Text(label,
          style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

// ─── Settings Tile ───
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                      style: GoogleFonts.notoSansTc(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ─── Font Size Tile ───
class _FontSizeTile extends StatelessWidget {
  final double currentSize;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _FontSizeTile({
    required this.currentSize,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.text_fields_rounded, size: 20, color: AppColors.accentEarth),
          const SizedBox(width: 12),
          Text('字體大小',
            style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: () => onChanged((currentSize - 2).clamp(12, 24)),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentEarth.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.text_decrease, size: 16, color: AppColors.accentEarth),
            ),
          ),
          SizedBox(
            width: 80,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: AppColors.accentEarth,
                inactiveTrackColor: AppColors.accentEarth.withValues(alpha: 0.15),
                thumbColor: AppColors.accentEarth,
              ),
              child: Slider(
                value: currentSize,
                min: 12,
                max: 24,
                divisions: 6,
                onChanged: onChanged,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged((currentSize + 2).clamp(12, 24)),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentEarth.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.text_increase, size: 16, color: AppColors.accentEarth),
            ),
          ),
          const SizedBox(width: 4),
          Text('${currentSize.round()}',
            style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600,
              color: AppColors.accentEarth)),
        ],
      ),
    );
  }
}

// ─── Age Selector ───
class _AgeSelector extends StatelessWidget {
  final String currentValue;
  final List<String> labels, values;
  final ValueChanged<String> onChanged;

  const _AgeSelector({
    required this.currentValue,
    required this.labels,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.celebration_rounded, size: 18, color: AppColors.accentCoral),
              const SizedBox(width: 8),
              Text('Life Stage Lens',
                style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('年齡篩選',
                  style: GoogleFonts.notoSansTc(fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.accentCoral)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(labels.length, (i) {
                final isSelected = values[i] == currentValue;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onChanged(values[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentCoral.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Text(labels[i],
                        style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.accentCoral : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                        )),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Text('內容將根據你嘅人生階段調整',
            style: GoogleFonts.notoSansTc(fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ─── Action Tile ───
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  Text(subtitle,
                    style: GoogleFonts.notoSansTc(fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
