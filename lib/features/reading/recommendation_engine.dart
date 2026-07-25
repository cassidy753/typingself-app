// ═══════════════════════════════════════════════════════════════════════
// RecommendationEngine — 推薦引擎
// 根據當前文章 + 用戶類型，智能推薦相關閱讀內容
// ═══════════════════════════════════════════════════════════════════════

import 'reading_content.dart';

/// Scoring-based recommendation engine for related articles
class RecommendationEngine {
  /// Get related book recommendations
  ///
  /// [currentBook] — the book the user is currently reading
  /// [userMbti] — user's MBTI type (e.g. "ENFJ"), falls back to the current
  ///              book's mbtiType if null
  /// [userEnnea] — user's Enneagram type (e.g. "4"), falls back to the current
  ///               book's enneaType if null
  /// [maxResults] — max recommendations to return (default 6)
  static List<ReadingBook> getRelated({
    required ReadingBook currentBook,
    String? userMbti,
    String? userEnnea,
    int maxResults = 6,
  }) {
    // Fall back to the current book's own type when user type isn't available
    final effectiveMbti =
        userMbti ?? (currentBook.mbtiType.isNotEmpty ? currentBook.mbtiType : null);
    final effectiveEnnea =
        userEnnea ?? (currentBook.enneaType.isNotEmpty ? currentBook.enneaType : null);

    final allBooks = ReadingContentProvider.allBooks;
    final scores = <ReadingBook, double>{};

    for (final book in allBooks) {
      // Skip the current book
      if (book.id == currentBook.id) continue;

      double score = 0;
      final reasons = <String>[]; // for debugging

      // ── Primary signals (same type, same category) ──

      // 1. Exact same MBTI type → strongly relevant (same person's primary book)
      if (_sameMbti(book, currentBook)) {
        score += 10;
        reasons.add('same-mbti');
      }

      // 2. Exact same Enneagram type → strongly relevant
      if (_sameEnnea(book, currentBook)) {
        score += 10;
        reasons.add('same-ennea');
      }

      // 3. Same category (e.g. both MBTI, both Growth)
      if (book.category == currentBook.category) {
        score += 4;
        reasons.add('same-category');
      }

      // ── Cross-category bridging signals ──

      // 4. Book's type matches user's MBTI type → bridge to relevant content
      //    (e.g. user is ENFJ, current book is Growth → recommend ENFJ book)
      if (effectiveMbti != null &&
          book.mbtiType.isNotEmpty &&
          book.mbtiType == effectiveMbti &&
          book.category != currentBook.category) {
        score += 5;
        reasons.add('cross-category-mbti');
      }

      // 5. Book's type matches user's Enneagram → bridge
      if (effectiveEnnea != null &&
          book.enneaType.isNotEmpty &&
          book.enneaType == effectiveEnnea &&
          book.category != currentBook.category) {
        score += 5;
        reasons.add('cross-category-ennea');
      }

      // 6. Current book has a type and this book is Growth/Shadow content
      //    that relates to that type (e.g. reading ENFJ → ENFJ growth articles)
      if ((currentBook.mbtiType.isNotEmpty || currentBook.enneaType.isNotEmpty) &&
          (book.category == 'Growth' || book.category == 'Shadow')) {
        score += 2;
        reasons.add('growth-shadow-related');
      }

      // 7. User's MBTI/Enneagram matches the book's type in any category
      //    (user's own type books always relevant)
      if (effectiveMbti != null &&
          book.mbtiType == effectiveMbti) {
        score += 3;
        if (!reasons.contains('cross-category-mbti')) {
          reasons.add('user-type-match');
        }
      }
      if (effectiveEnnea != null &&
          book.enneaType == effectiveEnnea) {
        score += 3;
        if (!reasons.contains('cross-category-ennea')) {
          reasons.add('user-type-match');
        }
      }

      // ── General relevance boosters ──

      // 8. Growth & Shadow content is universally useful
      if (book.category == 'Growth') score += 1;
      if (book.category == 'Shadow') score += 1;

      if (score > 0) {
        scores[book] = score;
      }
    }

    // Sort by score descending, then by title for stable ordering
    final sorted = scores.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return a.key.title.compareTo(b.key.title);
      });

    return sorted.take(maxResults).map((e) => e.key).toList();
  }

  /// Convenience: get recommendations that mix type-specific and general content
  static List<ReadingBook> getRecommendedForYou({
    required ReadingBook currentBook,
    String? userMbti,
    String? userEnnea,
  }) {
    return getRelated(
      currentBook: currentBook,
      userMbti: userMbti,
      userEnnea: userEnnea,
      maxResults: 6,
    );
  }

  // ─── Helpers ───

  static bool _sameMbti(ReadingBook a, ReadingBook b) =>
      a.mbtiType.isNotEmpty &&
      b.mbtiType.isNotEmpty &&
      a.mbtiType == b.mbtiType;

  static bool _sameEnnea(ReadingBook a, ReadingBook b) =>
      a.enneaType.isNotEmpty &&
      b.enneaType.isNotEmpty &&
      a.enneaType == b.enneaType;
}
