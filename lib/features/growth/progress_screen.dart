/// Progress Screen — weekly summary, streak display, difficulty trend, development timeline.
///
/// This is the full-screen growth progress view.
/// - Daily task completion bar chart (current week)
/// - Streak + total practice stats
/// - Difficulty trend (avg difficulty over recent weeks)
/// - Inferior function info card
/// - Development tips
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import 'growth_service.dart';
import 'inferior_function_data.dart';
import 'practice_tracker.dart';

class GrowthProgressScreen extends StatefulWidget {
  final String mbti;
  final String ennea;
  final Color accent;
  final Color accentBg;

  const GrowthProgressScreen({
    super.key,
    required this.mbti,
    required this.ennea,
    required this.accent,
    required this.accentBg,
  });

  @override
  State<GrowthProgressScreen> createState() => _GrowthProgressScreenState();
}

class _GrowthProgressScreenState extends State<GrowthProgressScreen> {
  List<PracticeEntry> _weekEntries = [];
  bool _loading = true;

  late final InferiorFunctionInfo _info;

  static const _weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    _info = getInferiorFunctionInfo(widget.mbti);
    _load();
  }

  Future<void> _load() async {
    final entries = await GrowthService.getWeekEntries();
    if (!mounted) return;
    setState(() {
      _weekEntries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // ── Section: Inferior Function Info ──
          _sectionHeader('🧩 你嘅劣勢功能'),
          const SizedBox(height: 8),
          _InferiorFunctionCard(info: _info, accent: widget.accent),
          const SizedBox(height: 20),

          // ── Section: Daily Practice ──
          _sectionHeader('🌱 今日練習'),
          const SizedBox(height: 8),
          DailyPracticeCard(mbti: widget.mbti, ennea: widget.ennea),
          const SizedBox(height: 20),

          // ── Section: Stats Overview ──
          _sectionHeader('📊 練習數據'),
          const SizedBox(height: 8),
          StreakRow(accent: widget.accent),
          const SizedBox(height: 20),

          // ── Section: Weekly Bar Chart ──
          _sectionHeader('📅 本週記錄'),
          const SizedBox(height: 8),
          _buildWeekChart(),
          const SizedBox(height: 20),

          // ── Section: Difficulty Trend ──
          _buildDifficultyFuture(),

          // ── Section: Tips ──
          _sectionHeader('💡 發展貼士'),
          const SizedBox(height: 8),
          _buildTipsCard(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(text, style: GoogleFonts.notoSerifTc(
      fontSize: 16, fontWeight: FontWeight.w700, color: widget.accent,
    ));
  }

  Widget _buildWeekChart() {
    if (_loading) return _shimmer();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_weekEntries.length, (i) {
            final e = _weekEntries[i];
            final maxHeight = 120.0;
            final barHeight = e.done ? maxHeight : (e.difficulty > 0 ? 30.0 : 20.0);
            final isToday = i == _weekEntries.length - 1;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Difficulty label (only for done items)
                    if (e.done)
                      Text('${e.difficulty}', style: TextStyle(
                        fontSize: 9, color: AppColors.textMuted,
                      )),
                    const SizedBox(height: 4),
                    // Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: e.done
                            ? widget.accent
                            : isToday
                                ? AppColors.border
                                : AppColors.border.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Day label
                    Text(
                      isToday ? '今日' : _weekdayLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isToday ? widget.accent : AppColors.textMuted,
                      ),
                    ),
                    // Date number
                    Text(
                      '${e.date.day}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isToday ? widget.accent : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDifficultyFuture() {
    return FutureBuilder<double?>(
      future: GrowthService.getWeekAvgDifficulty(),
      builder: (context, snap) {
        final avgDiff = snap.data;
        if (avgDiff == null || snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        String label;
        Color color;
        if (avgDiff <= 2.5) {
          label = '練習難度偏低，下一步可以挑戰大啲';
          color = AppColors.sage;
        } else if (avgDiff <= 3.5) {
          label = '難度適中，你呢個節奏好好';
          color = AppColors.mustard;
        } else {
          label = '練習偏難，可以考慮降低難度，唔好迫自己';
          color = AppColors.cta;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sectionHeader('📈 難度趨勢'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(avgDiff.toStringAsFixed(1), style: GoogleFonts.notoSerifTc(
                        fontSize: 22, fontWeight: FontWeight.w900, color: color,
                      )),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('平均難度', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(label, style: TextStyle(
                          fontSize: 13, color: AppColors.textPrimary, height: 1.4,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('🧠', style: TextStyle(fontSize: 18, color: widget.accent)),
              ),
              const SizedBox(width: 10),
              Text('給 ${widget.mbti} 嘅你', style: GoogleFonts.notoSansTc(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
            ],
          ),
          const SizedBox(height: 14),
          Text(_info.description, style: TextStyle(
            fontSize: 13, color: AppColors.textPrimary, height: 1.6,
          )),
          const SizedBox(height: 16),
          // Tips rows
          _tipRow('🎯', '每日做 5 分鐘就夠，唔好貪心'),
          const SizedBox(height: 8),
          _tipRow('📝', '記錄難度分，留意自己嘅進步'),
          const SizedBox(height: 8),
          _tipRow('🔥', '連續做 7 日嘅效果，好過一星期做一日'),
          const SizedBox(height: 8),
          _tipRow('💪', '唔舒服係正常 — 劣勢功能用起上嚟本身就係吃力'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _tipRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.4,
          )),
        ),
      ],
    );
  }

  Widget _shimmer() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _InferiorFunctionCard extends StatelessWidget {
  final InferiorFunctionInfo info;
  final Color accent;

  const _InferiorFunctionCard({required this.info, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('🕶️', style: TextStyle(fontSize: 24, color: accent)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('你的劣勢功能', style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary,
                )),
                const SizedBox(height: 4),
                Text(info.functionName, style: GoogleFonts.notoSerifTc(
                  fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                )),
                const SizedBox(height: 8),
                Text(info.description, style: TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.5,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
