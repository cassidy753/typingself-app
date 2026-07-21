// ═══════════════════════════════════════════════════════════════════════
// BookshelfScreen — 📚 書架 (Tab 1) — Edition 4
// 類似微信讀書書架 + Apple Books 閱讀目標風格
// 頭部：閱讀目標卡片（一週進度）
// 書架網格：每個「書」= 一個MBTI type / domain
// Filter chips: 全部 / 進行中 / 已完成 / 未開始
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/settings_service.dart';
import '../reading/reading_content.dart';
import '../reading/reading_screen.dart';

enum BookshelfFilter { all, inProgress, completed, notStarted }

class BookshelfScreen extends StatefulWidget {
  final String? mbti;
  final String? ennea;
  const BookshelfScreen({super.key, this.mbti, this.ennea});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  BookshelfFilter _filter = BookshelfFilter.all;
  bool _initialized = false;
  final SettingsService _settings = SettingsService();

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
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final books = ReadingContentProvider.allBooks;
    final completedIds = _settings.getCompletedBookIds();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build progress tracking per book
    final bookProgress = <String, double>{};
    for (final book in books) {
      if (completedIds.contains(book.id)) {
        bookProgress[book.id] = 1.0;
      }
    }

    // Filter books
    List<ReadingBook> filtered;
    switch (_filter) {
      case BookshelfFilter.inProgress:
        // Books with some progress but not completed
        filtered = books.where((b) => !completedIds.contains(b.id)).toList();
        if (filtered.isEmpty) {
          filtered = ReadingContentProvider.getRecommended(widget.mbti, widget.ennea);
        }
        break;
      case BookshelfFilter.completed:
        filtered = books.where((b) => completedIds.contains(b.id)).toList();
        break;
      case BookshelfFilter.notStarted:
        filtered = books.where((b) => !completedIds.contains(b.id)).toList();
        break;
      case BookshelfFilter.all:
        filtered = books;
    }

    // Calculate weekly stats
    final weeklyGoalMinutes = 60;
    final weeklyMinutes = _settings.totalReadingMinutes % weeklyGoalMinutes;
    final weeklyProgress = (weeklyMinutes / weeklyGoalMinutes).clamp(0.0, 1.0);

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: CustomScrollView(
        slivers: [
          // ── Weekly Reading Goal Card (Apple Books style) ──
          SliverToBoxAdapter(
            child: _WeeklyGoalCard(
              weeklyProgress: weeklyProgress,
              weeklyMinutes: weeklyMinutes,
              goalMinutes: weeklyGoalMinutes,
              totalReadingMinutes: _settings.totalReadingMinutes,
              completedBooks: completedIds.length,
              totalBooks: books.length,
              streakDays: _settings.streakDays,
            ),
          ),

          // ── Filter Chips ──
          SliverToBoxAdapter(
            child: _FilterChips(
              current: _filter,
              onChanged: (f) => setState(() => _filter = f),
              allCount: books.length,
              inProgressCount: books.length - completedIds.length,
              completedCount: completedIds.length,
            ),
          ),

          // ── Bookshelf grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _BookCard(
                  book: filtered[index],
                  isCompleted: completedIds.contains(filtered[index].id),
                  onTap: () => _openBook(filtered[index]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),

          // ── Bottom spacer ──
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  void _openBook(ReadingBook book) {
    _settings.booksStarted = _settings.booksStarted + 1;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(book: book),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}

// ─── Weekly Reading Goal Card (Apple Books style) ───
class _WeeklyGoalCard extends StatelessWidget {
  final double weeklyProgress;
  final int weeklyMinutes;
  final int goalMinutes;
  final int totalReadingMinutes;
  final int completedBooks;
  final int totalBooks;
  final int streakDays;

  const _WeeklyGoalCard({
    required this.weeklyProgress,
    required this.weeklyMinutes,
    required this.goalMinutes,
    required this.totalReadingMinutes,
    required this.completedBooks,
    required this.totalBooks,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = (totalReadingMinutes / 60).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentEarth.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, size: 18, color: AppColors.accentEarth),
                ),
                const SizedBox(width: 10),
                Text('本週閱讀目標',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text('${weeklyMinutes} / ${goalMinutes} 分鐘',
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress ring + stats
            Row(
              children: [
                // Circular progress
                SizedBox(
                  width: 60, height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60, height: 60,
                        child: CircularProgressIndicator(
                          value: weeklyProgress,
                          strokeWidth: 5,
                          backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentEarth),
                        ),
                      ),
                      Text('${(weeklyProgress * 100).round()}%',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentEarth,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Stats rows
                Expanded(
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.timer_outlined,
                        label: '總閱讀時數',
                        value: '${hours}h',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _StatRow(
                        icon: Icons.menu_book_rounded,
                        label: '已完成書本',
                        value: '$completedBooks/$totalBooks',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _StatRow(
                        icon: Icons.local_fire_department_rounded,
                        label: '連續閱讀',
                        value: '$streakDays 天',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label,
          style: GoogleFonts.notoSansTc(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(value,
          style: GoogleFonts.notoSansTc(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Filter Chips ───
class _FilterChips extends StatelessWidget {
  final BookshelfFilter current;
  final ValueChanged<BookshelfFilter> onChanged;
  final int allCount, inProgressCount, completedCount;

  const _FilterChips({
    required this.current,
    required this.onChanged,
    required this.allCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chips = [
      (BookshelfFilter.all, '全部', allCount),
      (BookshelfFilter.inProgress, '進行中', inProgressCount),
      (BookshelfFilter.completed, '已完成', completedCount),
      (BookshelfFilter.notStarted, '未開始', allCount - completedCount),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((c) {
            final active = current == c.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(c.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.accentEarth.withValues(alpha: 0.1)
                        : (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.accentEarth.withValues(alpha: 0.3)
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.$2,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? AppColors.accentEarth
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accentEarth.withValues(alpha: 0.15)
                              : (isDark ? AppColors.darkBorder : AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${c.$3}',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.accentEarth
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Book Card (Edition 4) ───
class _BookCard extends StatelessWidget {
  final ReadingBook book;
  final bool isCompleted;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverColor = int.tryParse(book.coverColor) ?? 0xFF9B72AA;

    return Semantics(
      label: '書本：${book.title}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(coverColor),
                        Color(coverColor).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      // Emoji
                      Center(
                        child: Text(book.emoji, style: const TextStyle(fontSize: 44)),
                      ),
                      // Completed badge
                      if (isCompleted)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accentSage,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.white),
                          ),
                        ),
                      // Category label
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(book.category,
                            style: GoogleFonts.notoSansTc(
                              fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info area
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(book.subtitle,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Mini progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isCompleted ? 1.0 : 0.0,
                        minHeight: 4,
                        backgroundColor: AppColors.accentDusty.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentDusty),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
