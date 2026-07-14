import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'quote_service.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> with SingleTickerProviderStateMixin {
  final _service = QuoteService();
  QuoteModel? _quote;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _load();
  }

  Future<void> _load() async {
    await _service.loadLocalQuotes();
    final weekday = DateTime.now().weekday;
    final cat = QuoteService.categoryForDay(weekday);
    if (mounted) {
      setState(() => _quote = _service.getRandomQuote(category: cat));
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_stories, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text('今日一句', style: GoogleFonts.notoSerifHk(
              fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
            )),
          ],
        ),
      ),
      body: SafeArea(
        child: _quote == null
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Day indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _categoryLabel(_quote!.category),
                          style: GoogleFonts.notoSansHk(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quote card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Decorative quote mark
                            Text('"', style: GoogleFonts.notoSerifHk(
                              fontSize: 64, fontWeight: FontWeight.w900,
                              color: AppColors.primary.withValues(alpha: 0.15),
                              height: 0.6,
                            )),
                            const SizedBox(height: 8),
                            Text(
                              _quote!.quote,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSerifHk(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                            if (_quote!.source != null && _quote!.source!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: 40,
                                height: 2,
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '— ${_quote!.source}',
                                style: GoogleFonts.notoSansHk(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: Text('分享呢句', style: GoogleFonts.notoSansHk(
                            fontSize: 14, fontWeight: FontWeight.w600,
                          )),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Mood teaser at bottom
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Text('💭', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '今日你點？撳低心情記錄低',
                                  style: GoogleFonts.notoSansHk(
                                    fontSize: 13, color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'movie': return '🎬 電影金句';
      case 'encouragement': return '💪 鼓勵說話';
      case 'inspirational': return '✨ 心靈雞湯';
      default: return '📖 每日一句';
    }
  }
}
