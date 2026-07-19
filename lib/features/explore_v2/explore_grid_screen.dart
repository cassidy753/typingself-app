// ═══════════════════════════════════════════════════════════════════════
// ExploreGridScreen — 🔍 探索 (Tab 2)
// 搜尋bar + 144 Combo圖譜（16×9 matrix grid）
// 分類scroll sections：MBTI 16型 / 九型9型 / 其他系統
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/settings_service.dart';
import '../reading/reading_content.dart';
import '../reading/reading_screen.dart';

class ExploreGridScreen extends StatefulWidget {
  final String? mbti;
  final String? ennea;
  final VoidCallback? onRetakeTest;
  const ExploreGridScreen({super.key, this.mbti, this.ennea, this.onRetakeTest});

  @override
  State<ExploreGridScreen> createState() => _ExploreGridScreenState();
}

class _ExploreGridScreenState extends State<ExploreGridScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _initialized = false;

  static const _mbtiTypes = [
    'ENFJ','INFJ','INTJ','ENTJ','ENFP','INFP','ENTP','INTP',
    'ESFJ','ISFJ','ESTJ','ISTJ','ESFP','ISFP','ESTP','ISTP',
  ];

  static const _enneaTypes = ['1','2','3','4','5','6','7','8','9'];

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Center(child: CircularProgressIndicator());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedIds = SettingsService().getCompletedBookIds();

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
            const SizedBox(height: 20),

            if (_searchQuery.isNotEmpty)
              _SearchResults(
                query: _searchQuery,
                books: ReadingContentProvider.allBooks,
                onTap: (book) => _openBook(book),
              )
            else ...[
              // ── 144 Combo Map ──
              _ComboMap(
                mbtiTypes: _mbtiTypes,
                enneaTypes: _enneaTypes,
                userMbti: widget.mbti,
                userEnnea: widget.ennea,
                completedIds: completedIds,
                onTap: (mbti, ennea) {
                  _openBookForType(mbti);
                },
              ),
              const SizedBox(height: 28),

              // ── MBTI 16 types ──
              _CategorySection(
                title: '🧠 MBTI 16型人格',
                books: ReadingContentProvider.getBooksByCategory('MBTI'),
                onTap: _openBook,
              ),
              const SizedBox(height: 24),

              // ── Enneagram 9 types ──
              _CategorySection(
                title: '🌀 九型人格 Enneagram',
                books: ReadingContentProvider.getBooksByCategory('Enneagram'),
                onTap: _openBook,
              ),
              const SizedBox(height: 24),

              // ── Growth series ──
              _CategorySection(
                title: '🌱 成長系列',
                books: ReadingContentProvider.getBooksByCategory('Growth'),
                onTap: _openBook,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  void _openBook(ReadingBook book) {
    SettingsService().booksStarted = SettingsService().booksStarted + 1;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReadingScreen(book: book)),
    );
  }

  void _openBookForType(String mbti) {
    final book = ReadingContentProvider.getBook(mbti.toLowerCase());
    if (book != null) _openBook(book);
  }
}

// ─── Search Bar ───
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '🔍 搜尋人格類型、主題...',
          hintStyle: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                  onPressed: () { controller.clear(); onChanged(''); },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: GoogleFonts.notoSansTc(fontSize: 15, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
    );
  }
}

// ─── 144 Combo Map ───
class _ComboMap extends StatelessWidget {
  final List<String> mbtiTypes;
  final List<String> enneaTypes;
  final String? userMbti;
  final String? userEnnea;
  final Set<String> completedIds;
  final void Function(String mbti, String ennea) onTap;

  const _ComboMap({
    required this.mbtiTypes,
    required this.enneaTypes,
    this.userMbti,
    this.userEnnea,
    required this.completedIds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🗺️', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('144 Combo 圖譜',
              style: GoogleFonts.notoSerifTc(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        Text('彩色 = 已讀，灰色 = 未讀',
          style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 12),

        // Horizontal scroll for the grid
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column headers (Enneagram numbers)
                Row(
                  children: [
                    const SizedBox(width: 48), // space for row labels
                    ...enneaTypes.map((e) => SizedBox(
                      width: 28,
                      child: Center(child: Text(e,
                        style: GoogleFonts.notoSansTc(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                // Rows (MBTI types)
                ...mbtiTypes.map((mbti) {
                  final isUserType = mbti == userMbti;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 46,
                          child: Text(mbti,
                            style: GoogleFonts.notoSansTc(
                              fontSize: 10,
                              fontWeight: isUserType ? FontWeight.w800 : FontWeight.w500,
                              color: isUserType ? AppColors.purple : AppColors.textMuted,
                            )),
                        ),
                        ...enneaTypes.map((ennea) {
                          final bookId = mbti.toLowerCase();
                          final isRead = completedIds.contains(bookId);
                          return GestureDetector(
                            onTap: () => onTap(mbti, ennea),
                            child: Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? AppColors.purple.withValues(alpha: 0.6)
                                    : AppColors.textMuted.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: isUserType
                                    ? Border.all(color: AppColors.purple.withValues(alpha: 0.4))
                                    : null,
                              ),
                              child: isUserType
                                  ? Center(child: Icon(Icons.star, size: 12, color: AppColors.mustard))
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Search Results ───
class _SearchResults extends StatelessWidget {
  final String query;
  final List<ReadingBook> books;
  final void Function(ReadingBook) onTap;

  const _SearchResults({
    required this.query,
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final results = books.where((b) =>
      b.title.toLowerCase().contains(query) ||
      b.subtitle.toLowerCase().contains(query) ||
      b.category.toLowerCase().contains(query) ||
      b.id.contains(query)
    ).toList();

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Text('🔍', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('搵唔到相關結果',
                style: GoogleFonts.notoSansTc(fontSize: 16, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('搜尋結果 (${results.length})',
          style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        ...results.map((book) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _BookSearchTile(book: book, onTap: () => onTap(book)),
        )),
      ],
    );
  }
}

class _BookSearchTile extends StatelessWidget {
  final ReadingBook book;
  final VoidCallback onTap;
  const _BookSearchTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverColor = int.tryParse(book.coverColor) ?? 0xFF9B72AA;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Color(coverColor).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(book.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                    style: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  Text(book.subtitle,
                    style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
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

// ─── Category Section ───
class _CategorySection extends StatelessWidget {
  final String title;
  final List<ReadingBook> books;
  final void Function(ReadingBook) onTap;

  const _CategorySection({
    required this.title,
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: GoogleFonts.notoSerifTc(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _HorizontalBookCard(
              book: books[i],
              onTap: () => onTap(books[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalBookCard extends StatelessWidget {
  final ReadingBook book;
  final VoidCallback onTap;
  const _HorizontalBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverColor = int.tryParse(book.coverColor) ?? 0xFF9B72AA;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(coverColor), Color(coverColor).withValues(alpha: 0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(book.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(book.title,
                style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
