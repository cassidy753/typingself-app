// ═══════════════════════════════════════════════════════════════════════
// BookshelfScreen — 📚 書架 (Tab 1)
// 類似微信讀書書架風格
// 頭部：閱讀狀態卡片（本週閱讀時數、完成度）
// 書架列表：每個「書」= 一個MBTI type / domain
// 進度條顯示閱讀%
// Filter tabs: 全部 / 進行中 / 已完成
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/settings_service.dart';
import '../reading/reading_content.dart';
import '../reading/reading_screen.dart';

enum BookshelfFilter { all, inProgress, completed }

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
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    // Filter books
    List<ReadingBook> filtered;
    switch (_filter) {
      case BookshelfFilter.inProgress:
        filtered = books.where((b) {
          // Books with some progress but not completed
          return !completedIds.contains(b.id) &&
              (b.id == widget.mbti?.toLowerCase() ||
               b.category == 'Growth');
        }).toList();
        // If we already completed some, still show max 3 in-progress
        break;
      case BookshelfFilter.completed:
        filtered = books.where((b) => completedIds.contains(b.id)).toList();
        break;
      case BookshelfFilter.all:
        filtered = books;
    }

    // If in-progress is empty, show recommended
    if (_filter == BookshelfFilter.inProgress && filtered.isEmpty) {
      filtered = ReadingContentProvider.getRecommended(widget.mbti, widget.ennea);
    }

    return Container(
      color: bgColor,
      child: CustomScrollView(
        slivers: [
          // ── Header: reading stats card ──
          SliverToBoxAdapter(
            child: _ReadingStatsCard(
              readingMinutes: _settings.totalReadingMinutes,
              completedBooks: _settings.booksCompleted,
              totalBooks: books.length,
              streakDays: _settings.streakDays,
            ),
          ),

          // ── Filter tabs ──
          SliverToBoxAdapter(
            child: _FilterTabs(
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
                childAspectRatio: 0.75,
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
      setState(() {}); // Refresh after returning
    });
  }
}

// ─── Reading Stats Card ───
class _ReadingStatsCard extends StatelessWidget {
  final int readingMinutes;
  final int completedBooks;
  final int totalBooks;
  final int streakDays;

  const _ReadingStatsCard({
    required this.readingMinutes,
    required this.completedBooks,
    required this.totalBooks,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = (readingMinutes / 60).toStringAsFixed(1);
    final progress = totalBooks > 0 ? (completedBooks / totalBooks) : 0.0;
    final bgCard = isDark ? AppColors.darkSurface : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purple.withValues(alpha: 0.15),
              AppColors.mustard.withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.purple.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reading time
                _StatChip(
                  icon: '⏱️',
                  value: '$hours hr',
                  label: '閱讀時數',
                  bgCard: bgCard,
                ),
                // Books completed
                _StatChip(
                  icon: '📚',
                  value: '$completedBooks/$totalBooks',
                  label: '完成書本',
                  bgCard: bgCard,
                ),
                // Streak
                _StatChip(
                  icon: '🔥',
                  value: '$streakDays',
                  label: '連續日數',
                  bgCard: bgCard,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.purple.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('閱讀進度',
                  style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
                Text('${(progress * 100).round()}%',
                  style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon, value, label;
  final Color bgCard;
  const _StatChip({required this.icon, required this.value, required this.label, required this.bgCard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.notoSerifTc(
            fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ─── Filter Tabs ───
class _FilterTabs extends StatelessWidget {
  final BookshelfFilter current;
  final ValueChanged<BookshelfFilter> onChanged;
  final int allCount, inProgressCount, completedCount;

  const _FilterTabs({
    required this.current,
    required this.onChanged,
    required this.allCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (BookshelfFilter.all, '全部', allCount),
      (BookshelfFilter.inProgress, '進行中', inProgressCount),
      (BookshelfFilter.completed, '已完成', completedCount),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: tabs.map((t) {
          final active = current == t.$1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onChanged(t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.purple.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: active
                        ? Border.all(color: AppColors.purple.withValues(alpha: 0.3))
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Text(
                    '${t.$2} (${t.$3})',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.purple : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Book Card ───
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
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Stack(
                    children: [
                      // Emoji
                      Center(
                        child: Text(book.emoji, style: const TextStyle(fontSize: 48)),
                      ),
                      // Completed badge
                      if (isCompleted)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8FA87A),
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
                        fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(book.subtitle,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 10, color: AppColors.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Mini progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isCompleted ? 1.0 : 0.0,
                        minHeight: 4,
                        backgroundColor: AppColors.purple.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
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
