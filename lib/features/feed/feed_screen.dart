// ═══════════════════════════════════════════════════════════════════════
// FeedScreen — 💬 動態 (Tab 3) — Edition 4
// 閱讀成就通知 + 閱讀紀錄timeline
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/settings_service.dart';
import '../reading/reading_content.dart';

class FeedScreen extends StatefulWidget {
  final String? mbti;
  final String? ennea;
  const FeedScreen({super.key, this.mbti, this.ennea});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final SettingsService _settings = SettingsService();
  bool _initialized = false;

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
    final completedBooks = ReadingContentProvider.allBooks
        .where((b) => completedIds.contains(b.id))
        .toList();

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('動態',
                    style: GoogleFonts.notoSerifTc(
                      fontSize: 24, fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('你嘅閱讀旅程記錄',
                    style: GoogleFonts.notoSansTc(fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ],
              ),
            ),
          ),

          // ── Achievements ──
          SliverToBoxAdapter(
            child: _AchievementSection(
              readingMinutes: _settings.totalReadingMinutes,
              completedCount: completedIds.length,
              streakDays: _settings.streakDays,
            ),
          ),

          // ── Timeline section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accentSage.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.timeline_rounded, size: 14, color: AppColors.accentSage),
                  ),
                  const SizedBox(width: 8),
                  Text('閱讀紀錄',
                    style: GoogleFonts.notoSerifTc(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _TimelineSection(
              completedBooks: completedBooks,
              streakDays: _settings.streakDays,
            ),
          ),

          // ── Bottom spacer ──
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── Achievement Section ───
class _AchievementSection extends StatelessWidget {
  final int readingMinutes;
  final int completedCount;
  final int streakDays;

  const _AchievementSection({
    required this.readingMinutes,
    required this.completedCount,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievements = <_Achievement>[
      _Achievement(
        emoji: '🎉',
        title: '閱讀新丁',
        desc: '讀完第1本書',
        unlocked: completedCount >= 1,
      ),
      _Achievement(
        emoji: '📚',
        title: '書蟲',
        desc: '讀完5本書',
        unlocked: completedCount >= 5,
      ),
      _Achievement(
        emoji: '🔥',
        title: '連續3日',
        desc: '連續3日閱讀',
        unlocked: streakDays >= 3,
      ),
      _Achievement(
        emoji: '💪',
        title: '連續7日',
        desc: '連續7日閱讀',
        unlocked: streakDays >= 7,
      ),
      _Achievement(
        emoji: '⏱️',
        title: '閱讀1小時',
        desc: '累計閱讀60分鐘',
        unlocked: readingMinutes >= 60,
      ),
      _Achievement(
        emoji: '🏆',
        title: '閱讀大師',
        desc: '讀完10本書',
        unlocked: completedCount >= 10,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.accentGold),
                ),
                const SizedBox(width: 8),
                Text('成就',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                const Spacer(),
                Text('${achievements.where((a) => a.unlocked).length}/${achievements.length}',
                  style: GoogleFonts.notoSansTc(fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: achievements.map((a) => _AchievementBadge(achievement: a)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Achievement {
  final String emoji, title, desc;
  final bool unlocked;
  const _Achievement({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.unlocked,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final opacity = achievement.unlocked ? 1.0 : 0.3;
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: achievement.unlocked ? 0.08 : 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.unlocked
                ? AppColors.accentGold.withValues(alpha: 0.2)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(achievement.title,
              style: GoogleFonts.notoSansTc(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Timeline Section ───
class _TimelineSection extends StatelessWidget {
  final List<ReadingBook> completedBooks;
  final int streakDays;

  const _TimelineSection({
    required this.completedBooks,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (completedBooks.isEmpty && streakDays == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Icon(Icons.menu_book_rounded, size: 48,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              const SizedBox(height: 12),
              Text('未有閱讀紀錄',
                style: GoogleFonts.notoSansTc(fontSize: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('去書架揀本書開始閱讀啦！',
                style: GoogleFonts.notoSansTc(fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    final timeline = <_TimelineEntry>[];

    // Add completion events
    for (final book in completedBooks) {
      timeline.add(_TimelineEntry(
        emoji: '✅',
        title: '完成閱讀《${book.title}》',
        subtitle: '你已經讀完咗呢本書，繼續探索更多！',
      ));
    }

    // Add streak events
    if (streakDays >= 7) {
      timeline.insert(0, _TimelineEntry(
        emoji: '🔥',
        title: '連續7日閱讀！',
        subtitle: '你已經連續7日使用型得你閱讀，繼續保持！',
      ));
    } else if (streakDays >= 3) {
      timeline.insert(0, _TimelineEntry(
        emoji: '🔥',
        title: '連續3日閱讀！',
        subtitle: '養成閱讀習慣中，加油！',
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: timeline.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == timeline.length - 1;
          return _TimelineItem(
            entry: item,
            isFirst: i == 0,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineEntry {
  final String emoji, title, subtitle;
  const _TimelineEntry({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineEntry entry;
  final bool isFirst, isLast;

  const _TimelineItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentEarth.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(entry.emoji, style: const TextStyle(fontSize: 14))),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.accentEarth.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(entry.subtitle,
                    style: GoogleFonts.notoSansTc(fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
