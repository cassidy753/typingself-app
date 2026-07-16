/// Daily Practice Tracker — a compact card for the growth home screen.
///
/// Shows:
/// - Today's practice task tailored to user's MBTI inferior function
/// - Difficulty slider (1-5)
/// - Mark-as-done button
/// - Streak indicator
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import 'growth_service.dart';
import 'inferior_function_data.dart';

class DailyPracticeCard extends StatefulWidget {
  final String mbti;
  final String ennea;

  const DailyPracticeCard({
    super.key,
    required this.mbti,
    required this.ennea,
  });

  @override
  State<DailyPracticeCard> createState() => _DailyPracticeCardState();
}

class _DailyPracticeCardState extends State<DailyPracticeCard> {
  bool _done = false;
  int _difficulty = 3;
  bool _loading = true;
  String? _note;

  String get _todayTask {
    final daySeed = DateTime.now().day + DateTime.now().month * 31;
    return getDailyTask(widget.mbti, daySeed);
  }

  InferiorFunctionInfo get _info => getInferiorFunctionInfo(widget.mbti);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entry = await GrowthService.getTodayEntry();
    if (!mounted) return;
    setState(() {
      _done = entry.done;
      _difficulty = entry.difficulty;
      _note = entry.note;
      _loading = false;
    });
  }

  Future<void> _toggle() async {
    final newDone = !_done;
    setState(() => _done = newDone);
    await GrowthService.saveTodayEntry(PracticeEntry(
      date: DateTime.now(),
      done: newDone,
      difficulty: _difficulty,
      note: _note,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _shimmerCard();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _done ? AppColors.sage.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('🌱', style: TextStyle(fontSize: 20, color: AppColors.sage)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('今日練習', style: GoogleFonts.notoSansTc(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 2),
                    Text('劣勢功能：${_info.functionName}', style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary,
                    )),
                  ],
                ),
              ),
              // Streak badge
              FutureBuilder<int>(
                future: GrowthService.getStreak(),
                builder: (context, snap) {
                  final streak = snap.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mustard.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text('$streak', style: GoogleFonts.notoSansTc(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.mustard,
                        )),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Task text ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📝', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _todayTask,
                    style: GoogleFonts.notoSansTc(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ── Difficulty slider ──
          Row(
            children: [
              Text('難度', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    activeTrackColor: AppColors.cta,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.cta,
                    overlayColor: AppColors.cta.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: _difficulty.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_difficulty',
                    onChanged: _done ? null : (v) => setState(() => _difficulty = v.round()),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text('$_difficulty', style: GoogleFonts.notoSansTc(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.cta,
                )),
              ),
            ],
          ),
          if (!_done) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Spacer(),
                Text('1 — 輕鬆', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(width: 20),
                Text('5 — 吃力', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(width: 40),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // ── CTA button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _done ? null : _toggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: _done ? AppColors.sage : AppColors.cta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w700),
                disabledBackgroundColor: AppColors.sage.withValues(alpha: 0.15),
                disabledForegroundColor: AppColors.sage,
              ),
              child: Text(_done ? '✅ 今日做咗！' : '✅ 完成練習'),
            ),
          ),
          if (!_done) ...[
            const SizedBox(height: 8),
            // ── Grip warning (subtle) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cta.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '壓力下有機會：${_info.gripWarning}',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  Widget _shimmerCard() {
    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20, width: 120, decoration: BoxDecoration(
            color: AppColors.skeleton, borderRadius: BorderRadius.circular(6),
          )),
          const SizedBox(height: 16),
          Container(height: 60, width: double.infinity, decoration: BoxDecoration(
            color: AppColors.skeleton, borderRadius: BorderRadius.circular(16),
          )),
          const SizedBox(height: 16),
          Container(height: 20, width: double.infinity, decoration: BoxDecoration(
            color: AppColors.skeleton, borderRadius: BorderRadius.circular(12),
          )),
        ],
      ),
    );
  }
}

/// A compact streak + completion row for embedding in a home screen.
class StreakRow extends StatelessWidget {
  final Color accent;
  const StreakRow({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: GrowthService.getStreak(),
      builder: (context, snap) {
        final streak = snap.data ?? 0;
        final total = FutureBuilder<int>(
          future: GrowthService.getTotalPractices(),
          builder: (c, s) => Text('${s.data ?? 0}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
        );
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Streak
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 6),
                        Text('$streak', style: GoogleFonts.notoSerifTc(
                          fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.mustard,
                        )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('連續日數', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              // Total
              Expanded(
                child: Column(
                  children: [
                    total,
                    const SizedBox(height: 4),
                    Text('累積練習', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              // Weekly completion
              Expanded(
                child: FutureBuilder<double>(
                  future: GrowthService.getWeekCompletionRate(),
                  builder: (c, s) {
                    final rate = (s.data ?? 0) * 100;
                    return Column(
                      children: [
                        Text('${rate.toInt()}%', style: GoogleFonts.notoSerifTc(
                          fontSize: 28, fontWeight: FontWeight.w900, color: accent,
                        )),
                        const SizedBox(height: 4),
                        Text('本週完成率', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
