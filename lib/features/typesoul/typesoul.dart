// ═══════════════════════════════════════════════════════════════════════
// TypeSoul — Data model for personality profile (MBTI × Enneagram combo)
// 432 profiles total (16 MBTI × 9 Enneagram cores × 3 variants each)
// Parsed from vault markdown source files
// ═══════════════════════════════════════════════════════════════════════

class TypeSoul {
  final String typeId;
  final String mbti;
  final String enneagram;
  final String nameCanto;
  final String emoji;

  /// 📖 核心描述 — opens with 「朋友形容佢：」
  final String coreDescription;

  /// 🎯 超能力 — 3 bullets
  final List<String> superpowers;

  /// ⚠️ 盲點 — 3 bullets
  final List<String> blindspots;

  /// 🌑 壓力下既佢 — shadow type description
  final String shadowDescription;

  /// 📈 成長路徑 — 4 steps + daily practice
  final List<String> growthPath;

  /// 💬 每日一句 — reflective quote in 書面語
  final String dailyQuote;

  /// 😂 寸嘴mode — Cantonese roast
  final String roastMode;

  const TypeSoul({
    required this.typeId,
    required this.mbti,
    required this.enneagram,
    required this.nameCanto,
    required this.emoji,
    required this.coreDescription,
    required this.superpowers,
    required this.blindspots,
    required this.shadowDescription,
    required this.growthPath,
    required this.dailyQuote,
    required this.roastMode,
  });
}
