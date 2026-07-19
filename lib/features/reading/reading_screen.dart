// ═══════════════════════════════════════════════════════════════════════
// ReadingScreen — 閱讀界面
// 顯示文章內容（emoji format、詩意標題）
// 底部progress bar
// 字體大小調整
// 語言風格切換
// 文章底部：相關文章推薦 + feedback buttons
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/settings_service.dart';
import 'reading_content.dart';

class ReadingScreen extends StatefulWidget {
  final ReadingBook book;
  const ReadingScreen({super.key, required this.book});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final SettingsService _settings = SettingsService();
  int _currentChapter = 0;
  int _currentSection = 0;
  double _fontSize = 16;
  bool _isNaturalCanto = false;
  final ScrollController _scrollCtrl = ScrollController();
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _fontSize = _settings.fontSize;
    _isNaturalCanto = _settings.isNaturalCanto;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  ReadingBook get _book => widget.book;
  ReadingChapter get _chapter => _book.chapters[_currentChapter];
  ReadingSection get _section => _chapter.sections[_currentSection];

  double get _progress {
    final totalSections = _book.totalSections;
    if (totalSections == 0) return 0;
    int pos = 0;
    for (int i = 0; i < _currentChapter; i++) {
      pos += _book.chapters[i].sections.length;
    }
    pos += _currentSection;
    return pos / totalSections;
  }

  bool get _hasNext {
    return _currentChapter < _book.chapters.length - 1 ||
        _currentSection < _chapter.sections.length - 1;
  }

  bool get _hasPrev {
    return _currentChapter > 0 || _currentSection > 0;
  }

  void _goNext() {
    if (_currentSection < _chapter.sections.length - 1) {
      setState(() { _currentSection++; });
    } else if (_currentChapter < _book.chapters.length - 1) {
      setState(() {
        _currentChapter++;
        _currentSection = 0;
      });
    }
    _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _goPrev() {
    if (_currentSection > 0) {
      setState(() { _currentSection--; });
    } else if (_currentChapter > 0) {
      setState(() {
        _currentChapter--;
        _currentSection = _book.chapters[_currentChapter].sections.length - 1;
      });
    }
    _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  String _transformContent(String content) {
    if (!_isNaturalCanto) return content;
    // Simple natural Canto transformations
    return content
        .replaceAll('嘅時候', '時')
        .replaceAll('嘅嘢', '嘢')
        .replaceAll('咗', '咗')
        .replaceAll('嗰啲', '啲')
        .replaceAll('呢啲', '呢啲');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF5EDE0);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // ── Progress bar ──
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 3,
              backgroundColor: AppColors.purple.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
            ),
          ),

          // ── Reading content ──
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showSettings = !_showSettings),
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chapter header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_chapter.emoji} ${_chapter.title}',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section title
                    Text(
                      _section.title,
                      style: GoogleFonts.notoSerifTc(
                        fontSize: _fontSize + 4,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section content (emoji formatted)
                    Text(
                      _transformContent(_section.content),
                      style: GoogleFonts.notoSansTc(
                        fontSize: _fontSize,
                        color: textColor,
                        height: 1.8,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Navigation buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_hasPrev)
                          _NavButton(
                            icon: Icons.arrow_back_rounded,
                            label: '上一頁',
                            onTap: _goPrev,
                          )
                        else
                          const SizedBox(width: 80),
                        if (_hasNext)
                          _NavButton(
                            icon: Icons.arrow_forward_rounded,
                            label: '下一頁',
                            isPrimary: true,
                            onTap: _goNext,
                          )
                        else
                          _NavButton(
                            icon: Icons.check_circle_outline,
                            label: '完成閱讀',
                            isPrimary: true,
                            onTap: () {
                              _settings.markBookCompleted(widget.book.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('🎉 已完成《${widget.book.title}》！',
                                  style: GoogleFonts.notoSansTc(fontSize: 14)),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Related books recommendation ──
                    _RelatedBooksSection(
                      currentBookId: widget.book.id,
                      books: ReadingContentProvider.getRecommended(
                        widget.book.mbtiType.isNotEmpty ? widget.book.mbtiType : null,
                        widget.book.enneaType.isNotEmpty ? widget.book.enneaType : null,
                      ),
                      onTap: (book) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ReadingScreen(book: book),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Feedback buttons ──
                    _FeedbackButtons(bookTitle: widget.book.title),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom settings bar (toggle on tap) ──
          if (_showSettings)
            _SettingsBar(
              fontSize: _fontSize,
              isNaturalCanto: _isNaturalCanto,
              onFontSizeChanged: (v) {
                setState(() => _fontSize = v);
                _settings.fontSize = v;
              },
              onLanguageToggle: () {
                setState(() => _isNaturalCanto = !_isNaturalCanto);
                _settings.languageStyle = _isNaturalCanto ? LanguageStyle.naturalCanto : LanguageStyle.writtenCanto;
              },
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_book.title,
            style: GoogleFonts.notoSansTc(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          Text('${_chapter.title} · ${_section.title}',
            style: GoogleFonts.notoSansTc(
              fontSize: 11, color: AppColors.textMuted),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.text_fields, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          onPressed: () => setState(() => _showSettings = !_showSettings),
        ),
      ],
    );
  }
}

// ─── Nav Button ───
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? AppColors.cta : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPrimary) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
            ],
            Text(label, style: GoogleFonts.notoSansTc(
              fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            if (isPrimary) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 18, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Settings Bar (bottom) ───
class _SettingsBar extends StatelessWidget {
  final double fontSize;
  final bool isNaturalCanto;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback onLanguageToggle;

  const _SettingsBar({
    required this.fontSize,
    required this.isNaturalCanto,
    required this.onFontSizeChanged,
    required this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        )),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Font size controls
            GestureDetector(
              onTap: () => onFontSizeChanged((fontSize - 2).clamp(12, 24)),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.text_decrease, size: 18, color: AppColors.purple),
              ),
            ),
            const SizedBox(width: 8),
            Text('${fontSize.round()}',
              style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onFontSizeChanged((fontSize + 2).clamp(12, 24)),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.text_increase, size: 18, color: AppColors.purple),
              ),
            ),

            const SizedBox(width: 16),
            Container(width: 1, height: 24, color: AppColors.divider),

            // Language toggle
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onLanguageToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cta.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(isNaturalCanto ? '🗣️' : '📝', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(isNaturalCanto ? '自然粵語' : '書面粵語',
                      style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.cta)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Related Books ───
class _RelatedBooksSection extends StatelessWidget {
  final String currentBookId;
  final List<ReadingBook> books;
  final void Function(ReadingBook) onTap;

  const _RelatedBooksSection({
    required this.currentBookId,
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final related = books.where((b) => b.id != currentBookId).take(3).toList();
    if (related.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📖 相關推薦',
          style: GoogleFonts.notoSerifTc(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...related.map((book) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onTap(book),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.purple.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Text(book.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title,
                          style: GoogleFonts.notoSansTc(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(book.subtitle,
                          style: GoogleFonts.notoSansTc(
                            fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ─── Feedback Buttons ───
class _FeedbackButtons extends StatefulWidget {
  final String bookTitle;
  const _FeedbackButtons({required this.bookTitle});

  @override
  State<_FeedbackButtons> createState() => _FeedbackButtonsState();
}

class _FeedbackButtonsState extends State<_FeedbackButtons> {
  String? _liked;

  final _buttons = [
    ('👍', '有用'),
    ('👎', '冇用'),
    ('🔖', '收藏'),
    ('📤', '分享'),
    ('✍️', '筆記'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('💬 你覺得呢篇文點？',
          style: GoogleFonts.notoSerifTc(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buttons.map((b) {
            final active = _liked == b.$1;
            return GestureDetector(
              onTap: () {
                setState(() => _liked = active ? null : b.$1);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(active ? '已取消' : '已記錄你嘅反饋 🙏',
                      style: GoogleFonts.notoSansTc(fontSize: 13)),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.purple.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: active
                      ? Border.all(color: AppColors.purple.withValues(alpha: 0.3))
                      : null,
                ),
                child: Column(
                  children: [
                    Text(b.$1, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 2),
                    Text(b.$2,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: active ? AppColors.purple : AppColors.textMuted)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
