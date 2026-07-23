import 'dart:ui' show Color, FontWeight;

class TypeParticle {
  final String code;
  final String name;
  final String archetype;
  final double x, y, z;
  final double speed;
  final double baseSize;
  final FontWeight weight;
  final Color color;

  const TypeParticle(this.code, this.name, this.archetype, {
    required this.x, required this.y, required this.z, required this.speed,
    required this.baseSize, required this.weight, required this.color,
  });
}

// 34 personality types — each with individual archetype, size, weight, color
final List<TypeParticle> typeData = [
  // ─── NT — 理性主義者 ───
  TypeParticle('INTJ', '戰略家', '智者', x: -1.8, y: -2.1, z: 3.0, speed: 0.7, baseSize: 28, weight: FontWeight.w900, color: Color(0xFF7B5EA7)),
  TypeParticle('INTP', '思考家', '邏輯學家', x: 2.2, y: -1.8, z: 4.2, speed: 0.5, baseSize: 24, weight: FontWeight.w600, color: Color(0xFF5B8DB8)),
  TypeParticle('ENTJ', '指揮官', '統帥', x: -0.5, y: -2.8, z: 5.0, speed: 0.4, baseSize: 32, weight: FontWeight.w900, color: Color(0xFFA04030)),
  TypeParticle('ENTP', '辯論家', '創新者', x: 3.0, y: -1.2, z: 2.8, speed: 0.8, baseSize: 22, weight: FontWeight.w500, color: Color(0xFFD4956B)),

  // ─── NF — 理想主義者 ───
  TypeParticle('INFJ', '靈性導師', '引路人', x: -2.5, y: 0.2, z: 3.5, speed: 0.6, baseSize: 26, weight: FontWeight.w700, color: Color(0xFF8B6BAE)),
  TypeParticle('INFP', '夢想家', '永恆少年', x: 1.5, y: 0.8, z: 4.8, speed: 0.45, baseSize: 20, weight: FontWeight.w400, color: Color(0xFFA88CB8)),
  TypeParticle('ENFJ', '教育家', '導師', x: -3.2, y: 1.5, z: 2.5, speed: 0.9, baseSize: 30, weight: FontWeight.w800, color: Color(0xFF6BB87B)),
  TypeParticle('ENFP', '探索家', '永恆少年', x: 2.8, y: 1.8, z: 3.8, speed: 0.55, baseSize: 24, weight: FontWeight.w500, color: Color(0xFF8FC4A0)),

  // ─── SJ — 監護人 ───
  TypeParticle('ISTJ', '審查官', '守護者', x: -0.8, y: -1.5, z: 5.5, speed: 0.35, baseSize: 18, weight: FontWeight.w600, color: Color(0xFF5A6B7A)),
  TypeParticle('ISFJ', '守護者', '照顧者', x: 3.5, y: -0.5, z: 4.5, speed: 0.5, baseSize: 20, weight: FontWeight.w500, color: Color(0xFF7A9B8A)),
  TypeParticle('ESTJ', '管理者', '監督者', x: -2.0, y: -0.8, z: 6.0, speed: 0.3, baseSize: 16, weight: FontWeight.w700, color: Color(0xFFB88A5A)),
  TypeParticle('ESFJ', '照顧者', '提供者', x: 0.5, y: -2.5, z: 5.2, speed: 0.4, baseSize: 18, weight: FontWeight.w500, color: Color(0xFFC4A07A)),

  // ─── SP — 工匠 ───
  TypeParticle('ISTP', '工匠', '巧手者', x: 4.0, y: 0.5, z: 3.2, speed: 0.75, baseSize: 22, weight: FontWeight.w500, color: Color(0xFF6B8F8B)),
  TypeParticle('ISFP', '藝術家', '創作者', x: -1.2, y: 2.2, z: 4.0, speed: 0.6, baseSize: 20, weight: FontWeight.w400, color: Color(0xFFC48BA8)),
  TypeParticle('ESTP', '冒險家', '實踐者', x: 1.0, y: -1.0, z: 6.5, speed: 0.25, baseSize: 14, weight: FontWeight.w600, color: Color(0xFFD4A060)),
  TypeParticle('ESFP', '表演者', '表演者', x: -3.5, y: -1.8, z: 3.0, speed: 0.85, baseSize: 26, weight: FontWeight.w500, color: Color(0xFFE0A080)),

  // ─── Enneagram Wings ───
  TypeParticle('1w9', '理想主義者', '改革家', x: -1.5, y: 2.8, z: 2.0, speed: 1.0, baseSize: 20, weight: FontWeight.w600, color: Color(0xFF88A0C0)),
  TypeParticle('2w1', '僕人', '助人者', x: 2.5, y: 2.5, z: 2.5, speed: 0.9, baseSize: 18, weight: FontWeight.w500, color: Color(0xFFC0A088)),
  TypeParticle('2w3', '東道主', '款待者', x: -2.8, y: -0.2, z: 4.8, speed: 0.45, baseSize: 16, weight: FontWeight.w400, color: Color(0xFFD4B080)),
  TypeParticle('3w2', '魅力者', '成就者', x: 0.8, y: 3.0, z: 2.2, speed: 1.1, baseSize: 22, weight: FontWeight.w700, color: Color(0xFFE0A060)),
  TypeParticle('3w4', '專業人士', '精英', x: -4.0, y: 0.0, z: 3.5, speed: 0.65, baseSize: 16, weight: FontWeight.w600, color: Color(0xFFB88870)),
  TypeParticle('4w3', '貴族', '獨特者', x: 3.8, y: -2.0, z: 2.8, speed: 0.8, baseSize: 18, weight: FontWeight.w500, color: Color(0xFFC08090)),
  TypeParticle('4w5', '自由 thinkers', '個人主義者', x: -1.0, y: 3.5, z: 2.0, speed: 1.2, baseSize: 20, weight: FontWeight.w400, color: Color(0xFF8B80A8)),
  TypeParticle('5w4', '高級KAM L', '圖騰', x: 2.0, y: 3.2, z: 2.5, speed: 1.0, baseSize: 18, weight: FontWeight.w700, color: Color(0xFF7B6B9B)),
  TypeParticle('5w6', '守護者', '思想守護者', x: -3.0, y: 2.0, z: 3.0, speed: 0.75, baseSize: 16, weight: FontWeight.w500, color: Color(0xFF6B7B8B)),
  TypeParticle('6w5', '防衛者', '忠誠者', x: 4.2, y: -2.5, z: 2.5, speed: 0.9, baseSize: 14, weight: FontWeight.w600, color: Color(0xFF8B8B6B)),
  TypeParticle('6w7', '伙伴', '盟友', x: -2.2, y: 3.8, z: 2.0, speed: 1.1, baseSize: 16, weight: FontWeight.w500, color: Color(0xFFA0986B)),
  TypeParticle('7w6', '表演者', '享樂者', x: 1.8, y: -3.0, z: 3.5, speed: 0.6, baseSize: 18, weight: FontWeight.w400, color: Color(0xFFD4A060)),
  TypeParticle('7w8', '現實主義者', '物質主義者', x: -3.8, y: -2.5, z: 2.8, speed: 0.85, baseSize: 14, weight: FontWeight.w600, color: Color(0xFFD4B080)),
  TypeParticle('8w7', '獨立者', '挑戰者', x: 0.2, y: 3.8, z: 1.8, speed: 1.3, baseSize: 22, weight: FontWeight.w800, color: Color(0xFFA06050)),
  TypeParticle('8w9', '熊', '溫和強者', x: -4.5, y: -1.0, z: 2.5, speed: 0.95, baseSize: 16, weight: FontWeight.w700, color: Color(0xFF8B7060)),
  TypeParticle('9w8', '安逸者', '輕鬆者', x: 3.2, y: 3.5, z: 2.0, speed: 1.2, baseSize: 18, weight: FontWeight.w400, color: Color(0xFFA0A080)),
  TypeParticle('9w1', '和平者', '調和者', x: -0.5, y: -3.5, z: 4.0, speed: 0.55, baseSize: 16, weight: FontWeight.w500, color: Color(0xFF8BA88B)),
  TypeParticle('1w2', '活動家', '改革者', x: 4.5, y: 1.2, z: 2.2, speed: 1.1, baseSize: 14, weight: FontWeight.w600, color: Color(0xFF88A0A0)),
];
