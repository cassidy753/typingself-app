import 'dart:ui' show Color;

class TypeParticle {
  final String code;       // INTJ
  final String name;       // 戰略家
  final String archetype;  // 永恆少年、智者、工匠…
  final double x, y, z;    // 3D world position
  final double speed;      // fly speed
  final double baseSize;   // base font size (before perspective)
  final FontWeight weight;  // font weight
  final Color color;       // individual color

  const TypeParticle(this.code, this.name, this.archetype, {
    required this.x, required this.y, required this.z, required this.speed,
    required this.baseSize, required this.weight, required this.color,
  });
}
