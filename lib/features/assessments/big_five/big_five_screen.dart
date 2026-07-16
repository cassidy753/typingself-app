// ═══════════════════════════════════════════════════════════════════════
// BigFiveScreen — 大五人格問卷 Screen
// 10 scenario questions with 5-option Likert scale + progress
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import 'big_five_model.dart';
import 'big_five_questions.dart';
import 'big_five_scorer.dart';
import 'big_five_result_screen.dart';

class BigFiveScreen extends StatefulWidget {
  final void Function(BigFiveResult result)? onComplete;
  const BigFiveScreen({super.key, this.onComplete});

  @override
  State<BigFiveScreen> createState() => _BigFiveScreenState();
}

class _BigFiveScreenState extends State<BigFiveScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final Map<String, int> _answers = {};
  late final List<BigFiveQuestion> _questions;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _questions = BigFiveQuestions.all;
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.03, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_selectedIndex != null) return;
    setState(() => _selectedIndex = index);

    final q = _questions[_currentIndex];
    final score = q.options[index].score;
    _answers[q.id] = score;

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedIndex = null;
        });
        _slideCtrl.reset();
        _slideCtrl.forward();
      } else {
        _finish();
      }
    });
  }

  void _finish() {
    final result = BigFiveScorer.calculate(_answers);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BigFiveResultScreen(
          result: result,
          onComplete: () {
            widget.onComplete?.call(result);
          },
        ),
      ),
    );
  }

  void _goBack() {
    if (_currentIndex > 0) {
      final prevQ = _questions[_currentIndex - 1];
      _answers.remove(prevQ.id);
      setState(() {
        _currentIndex--;
        _selectedIndex = null;
      });
      _slideCtrl.reset();
      _slideCtrl.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final progress = (_currentIndex + 1) / total;
    final q = _questions[_currentIndex];

    // Dimension icons
    const dimIcons = {'O': '🌍', 'C': '🎯', 'E': '🗣️', 'A': '💛', 'N': '🌊'};
    const dimNames = {
      'O': '開放性',
      'C': '盡責性',
      'E': '外向性',
      'A': '親和性',
      'N': '神經質'
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header: Back + Progress ───
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: Icon(Icons.arrow_back_rounded,
                        color: AppColors.textSecondary, size: 24),
                    splashRadius: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dimIcons[q.dimension] ?? ''} ${dimNames[q.dimension] ?? q.dimension}',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cta,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cta,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${_currentIndex + 1}/$total',
                      style: GoogleFonts.notoSansTc(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Question ───
            Expanded(
              child: SlideTransition(
                position: _slideIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          q.scenario,
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: q.options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final opt = q.options[i];
                            final isSelected = _selectedIndex == i;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              child: SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: _selectedIndex != null
                                      ? null
                                      : () => _selectOption(i),
                                  style: TextButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    backgroundColor: isSelected
                                        ? AppColors.cta.withValues(alpha: 0.12)
                                        : AppColors.surface,
                                    foregroundColor: isSelected
                                        ? AppColors.cta
                                        : AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.cta
                                            : _selectedIndex != null
                                                ? AppColors.border.withValues(alpha: 0.5)
                                                : AppColors.border,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    textStyle: GoogleFonts.notoSansTc(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.cta
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.cta
                                                : AppColors.textMuted,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check,
                                                size: 14, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(child: Text(opt.text)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Bottom hint ───
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                '揀一個最接近你嘅答案',
                style: GoogleFonts.notoSansTc(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
