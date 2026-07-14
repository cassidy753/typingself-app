import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteModel {
  final String quote;
  final String? source;
  final String category;

  QuoteModel({
    required this.quote,
    this.source,
    required this.category,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quote: json['quote'] ?? '',
      source: json['source'],
      category: json['category'] ?? 'inspirational',
    );
  }

  String get displayText {
    if (source != null && source!.isNotEmpty) {
      return '$quote\n\n— $source';
    }
    return quote;
  }
}

class QuoteService {
  List<QuoteModel> _localQuotes = [];
  final _random = Random();

  Future<void> loadLocalQuotes() async {
    final jsonStr = await rootBundle.loadString('assets/quotes/seed_quotes.json');
    final List<dynamic> data = json.decode(jsonStr);
    _localQuotes = data.map((e) => QuoteModel.fromJson(e)).toList();
  }

  QuoteModel getRandomQuote({String? category}) {
    final pool = category != null
        ? _localQuotes.where((q) => q.category == category).toList()
        : _localQuotes;
    return pool[_random.nextInt(pool.length)];
  }

  QuoteModel getQuoteForDay(int dayOfYear) {
    // Deterministic quote by day (same quote all day for all users)
    final idx = dayOfYear % _localQuotes.length;
    return _localQuotes[idx];
  }

  Future<String> getLastReadQuoteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_quote_id') ?? '';
  }

  Future<void> markQuoteRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_quote_id', id);
  }

  // Categories by day of week
  static String categoryForDay(int weekday) {
    switch (weekday) {
      case 1: return 'inspirational';  // Sun
      case 2: return 'movie';          // Mon
      case 3: return 'inspirational';  // Tue
      case 4: return 'movie';          // Wed
      case 5: return 'encouragement';  // Thu
      case 6: return 'movie';          // Fri
      case 7: return 'encouragement';  // Sat
      default: return 'inspirational';
    }
  }
}
