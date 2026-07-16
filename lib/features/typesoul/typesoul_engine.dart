import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'typesoul.dart';

class TypeSoulEngine {
  static List<TypeSoul> _cache = [];
  static bool _loaded = false;

  static Future<void> init() async {
    final json = await rootBundle.loadString('assets/typesoul_full.json');
    final list = jsonDecode(json) as List;
    _cache = list.map((e) => TypeSoul(
      typeId: e['typeId'] ?? '',
      mbti: e['mbti'] ?? '',
      enneagram: e['enneagram'] ?? '',
      nameCanto: e['nameCanto'] ?? '',
      emoji: e['emoji'] ?? '🧠',
      coreDescription: e['coreDescription'] ?? '',
      superpowers: List<String>.from(e['superpowers'] ?? []),
      blindspots: List<String>.from(e['blindspots'] ?? []),
      shadowDescription: e['shadowDescription'] ?? '',
      growthPath: List<String>.from(e['growthPath'] ?? []),
      dailyQuote: e['dailyQuote'] ?? '',
      roastMode: e['roastMode'] ?? '',
    )).toList();
    _loaded = true;
  }

  static TypeSoul? lookUp(String mbti, String ennea) {
    if (!_loaded) return null;
    for (final ts in _cache) {
      if (ts.mbti == mbti && ts.enneagram == ennea) return ts;
    }
    return null;
  }

  static List<TypeSoul> forMbti(String mbti) {
    if (!_loaded) return [];
    return _cache.where((ts) => ts.mbti == mbti).toList();
  }

  static int get count => _cache.length;
}
