import 'dart:ui' show Color;

class _TypeParticle {
  final String en, zh;
  final double x, y, z;
  final double speed;
  final Color color;

  const _TypeParticle(this.en, this.zh, {required this.x, required this.y, required this.z, required this.speed, required this.color});
}

final typeData = <_TypeParticle>[
  _TypeParticle('INTJ', '戰略家', x: -1.8, y: -2.1, z: 3.0, speed: 0.7, color: Color(0xFF7B5EA7)),
  _TypeParticle('INTP', '思考家', x: 2.2, y: -1.8, z: 4.2, speed: 0.5, color: Color(0xFF5B8DB8)),
  _TypeParticle('ENTJ', '指揮官', x: -0.5, y: -2.8, z: 5.0, speed: 0.4, color: Color(0xFFA04030)),
  _TypeParticle('ENTP', '辯論家', x: 3.0, y: -1.2, z: 2.8, speed: 0.8, color: Color(0xFFD4956B)),
  _TypeParticle('INFJ', '靈性導師', x: -2.5, y: 0.2, z: 3.5, speed: 0.6, color: Color(0xFF8B6BAE)),
  _TypeParticle('INFP', '夢想家', x: 1.5, y: 0.8, z: 4.8, speed: 0.45, color: Color(0xFFA88CB8)),
  _TypeParticle('ENFJ', '教育家', x: -3.2, y: 1.5, z: 2.5, speed: 0.9, color: Color(0xFF6BB87B)),
  _TypeParticle('ENFP', '探索家', x: 2.8, y: 1.8, z: 3.8, speed: 0.55, color: Color(0xFF8FC4A0)),
  _TypeParticle('ISTJ', '審查官', x: -0.8, y: -1.5, z: 5.5, speed: 0.35, color: Color(0xFF5A6B7A)),
  _TypeParticle('ISFJ', '守護者', x: 3.5, y: -0.5, z: 4.5, speed: 0.5, color: Color(0xFF7A9B8A)),
  _TypeParticle('ESTJ', '管理者', x: -2.0, y: -0.8, z: 6.0, speed: 0.3, color: Color(0xFFB88A5A)),
  _TypeParticle('ESFJ', '照顧者', x: 0.5, y: -2.5, z: 5.2, speed: 0.4, color: Color(0xFFC4A07A)),
  _TypeParticle('ISTP', '工匠', x: 4.0, y: 0.5, z: 3.2, speed: 0.75, color: Color(0xFF6B8F8B)),
  _TypeParticle('ISFP', '藝術家', x: -1.2, y: 2.2, z: 4.0, speed: 0.6, color: Color(0xFFC48BA8)),
  _TypeParticle('ESTP', '冒險家', x: 1.0, y: -1.0, z: 6.5, speed: 0.25, color: Color(0xFFD4A060)),
  _TypeParticle('ESFP', '表演者', x: -3.5, y: -1.8, z: 3.0, speed: 0.85, color: Color(0xFFE0A080)),
  _TypeParticle('1w9', '理想主義者', x: -1.5, y: 2.8, z: 2.0, speed: 1.0, color: Color(0xFF88A0C0)),
  _TypeParticle('2w1', '僕人', x: 2.5, y: 2.5, z: 2.5, speed: 0.9, color: Color(0xFFC0A088)),
  _TypeParticle('2w3', '東道主', x: -2.8, y: -0.2, z: 4.8, speed: 0.45, color: Color(0xFFD4B080)),
  _TypeParticle('3w2', '魅力者', x: 0.8, y: 3.0, z: 2.2, speed: 1.1, color: Color(0xFFE0A060)),
  _TypeParticle('3w4', '專業人士', x: -4.0, y: 0.0, z: 3.5, speed: 0.65, color: Color(0xFFB88870)),
  _TypeParticle('4w3', '貴族', x: 3.8, y: -2.0, z: 2.8, speed: 0.8, color: Color(0xFFC08090)),
  _TypeParticle('4w5', '自由 thinkers', x: -1.0, y: 3.5, z: 2.0, speed: 1.2, color: Color(0xFF8B80A8)),
  _TypeParticle('5w4', '高級KAM L', x: 2.0, y: 3.2, z: 2.5, speed: 1.0, color: Color(0xFF7B6B9B)),
  _TypeParticle('5w6', '守護者', x: -3.0, y: 2.0, z: 3.0, speed: 0.75, color: Color(0xFF6B7B8B)),
  _TypeParticle('6w5', '防衛者', x: 4.2, y: -2.5, z: 2.5, speed: 0.9, color: Color(0xFF8B8B6B)),
  _TypeParticle('6w7', '伙伴', x: -2.2, y: 3.8, z: 2.0, speed: 1.1, color: Color(0xFFA0986B)),
  _TypeParticle('7w6', '表演者', x: 1.8, y: -3.0, z: 3.5, speed: 0.6, color: Color(0xFFD4A060)),
  _TypeParticle('7w8', '現實主義者', x: -3.8, y: -2.5, z: 2.8, speed: 0.85, color: Color(0xFFD4B080)),
  _TypeParticle('8w7', '獨立者', x: 0.2, y: 3.8, z: 1.8, speed: 1.3, color: Color(0xFFA06050)),
  _TypeParticle('8w9', '熊', x: -4.5, y: -1.0, z: 2.5, speed: 0.95, color: Color(0xFF8B7060)),
  _TypeParticle('9w8', '安逸者', x: 3.2, y: 3.5, z: 2.0, speed: 1.2, color: Color(0xFFA0A080)),
  _TypeParticle('9w1', '和平者', x: -0.5, y: -3.5, z: 4.0, speed: 0.55, color: Color(0xFF8BA88B)),
  _TypeParticle('1w2', '活動家', x: 4.5, y: 1.2, z: 2.2, speed: 1.1, color: Color(0xFF88A0A0)),
];
