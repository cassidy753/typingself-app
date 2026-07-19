// ═══════════════════════════════════════════════════════════════════════
// ProfileV2Screen — 👤 我 (Tab 4)
// 閱讀統計Dashboard（已探索combo數、閱讀時數、連續日數）
// 用戶MBTI+九型結果
// 設定（語言風格toggle、深色模式、字體大小）
// 年齡選擇器（Life Stage Lens）
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
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text('👤 我',
              style: GoogleFonts.notoSerifTc(
                fontSize: 28, fontWeight: FontWeight.w900,
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
            Text('⚙️ 設定',
              style: GoogleFonts.notoSerifTc(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            const SizedBox(height: 12),

            // Dark mode toggle
            _SettingsTile(
              icon: isDark ? '🌙' : '☀️',
              title: '深色模式',
              trailing: Switch.adaptive(
                value: _settings.darkMode,
                activeColor: AppColors.purple,
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
              icon: _settings.isNaturalCanto ? '🗣️' : '📝',
              title: '語言風格',
              subtitle: _settings.isNaturalCanto ? '自然粵語' : '書面粵語',
              trailing: Switch.adaptive(
                value: _settings.isNaturalCanto,
                activeColor: AppColors.cta,
                onChanged: (v) {
                  _settings.languageStyle = v ? LanguageStyle.naturalCanto : LanguageStyle.writtenCanto;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 8),

            // Font size
            _SettingsTile(
              icon: '🔤',
              title: '字體大小',
              subtitle: '${_settings.fontSize.round()}px',
              trailing: SizedBox(
                width: 140,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _settings.fontSize = _settings.fontSize - 2;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.text_decrease, size: 16, color: AppColors.purple),
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: AppColors.purple,
                          inactiveTrackColor: AppColors.purple.withValues(alpha: 0.15),
                          thumbColor: AppColors.purple,
                        ),
                        child: Slider(
                          value: _settings.fontSize,
                          min: 12,
                          max: 24,
                          divisions: 6,
                          onChanged: (v) {
                            _settings.fontSize = v;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _settings.fontSize = _settings.fontSize + 2;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.text_increase, size: 16, color: AppColors.purple),
                      ),
                    ),
                  ],
                ),
              ),
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
            Text('📋 更多',
              style: GoogleFonts.notoSerifTc(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            const SizedBox(height: 12),

            _ActionTile(
              icon: '🧪',
              title: '重新做人格測試',
              subtitle: '清除結果，重新開始',
              onTap: widget.onRetakeTest,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: '⚙️',
              title: '進階設定',
              subtitle: '星座・同意・資料管理',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      accent: AppColors.purple,
                      accentBg: AppColors.purple.withValues(alpha: 0.12),
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
              icon: '📄',
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
            AppColors.purple,
            AppColors.purple.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: Text(
              isCompleted ? _getEmoji(mbti) : '🧠',
              style: const TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 12),
          Text(
            isCompleted ? _getName(mbti) : '未進行測試',
            style: GoogleFonts.notoSerifTc(
              fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
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
          const SizedBox(height: 12),
          if (onRetake != null)
            GestureDetector(
              onTap: onRetake,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 閱讀統計',
            style: GoogleFonts.notoSerifTc(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatTile(icon: '🗺️', value: '$comboCount', label: '已探索Combo', accent: AppColors.purple)),
              Expanded(child: _StatTile(icon: '⏱️', value: '${hours}h', label: '閱讀時數', accent: AppColors.cta)),
              Expanded(child: _StatTile(icon: '🔥', value: '$streakDays', label: '連續日數', accent: AppColors.mustard)),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalBooks > 0 ? completedBooks / totalBooks : 0,
              minHeight: 8,
              backgroundColor: AppColors.purple.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('書本完成度',
                style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
              Text('$completedBooks/$totalBooks',
                style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.purple)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon, value, label;
  final Color accent;
  const _StatTile({required this.icon, required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
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
  final String icon, title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
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
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
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
                      style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
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
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🎂', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Life Stage Lens',
                style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('年齡篩選',
                  style: GoogleFonts.notoSansTc(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.cta)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (i) {
              final isSelected = values[i] == currentValue;
              return GestureDetector(
                onTap: () => onChanged(values[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.cta.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.cta.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Text(labels[i],
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.cta : AppColors.textMuted,
                    )),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text('內容將根據你嘅人生階段調整',
            style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ─── Action Tile ───
class _ActionTile extends StatelessWidget {
  final String icon, title, subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
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
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  Text(subtitle,
                    style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
