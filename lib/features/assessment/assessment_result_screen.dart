// ═══════════════════════════════════════════════════════════════════════
// AssessmentResultScreen — 結果頁 (Type + NamingCard + Share + Save)
// Integrates NamingEngine 289 entries for the final personality name
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../personality_naming/naming_engine.dart';
import '../personality_naming/share_card.dart';
import 'decision_tree_engine.dart';

class AssessmentResultScreen extends ConsumerStatefulWidget {
  final String mbti;
  final String ennea;
  final DecisionTreeEngine engine;
  final void Function(String mbti, String ennea) onComplete;

  const AssessmentResultScreen({
    super.key,
    required this.mbti,
    required this.ennea,
    required this.engine,
    required this.onComplete,
  });

  @override
  ConsumerState<AssessmentResultScreen> createState() =>
      _AssessmentResultScreenState();
}

class _AssessmentResultScreenState
    extends ConsumerState<AssessmentResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  int _selectedTagline = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _saveResult();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_done', true);
    await prefs.setString('mbti', widget.mbti);
    await prefs.setString('ennea', widget.ennea);
  }

  @override
  Widget build(BuildContext context) {
    // Look up naming with safe fallback
    final name = NamingEngine.getName(widget.mbti, widget.ennea) ??
        NamingEngine.getName('ENFJ', '5w4') ??
        PersonalityName(
          mbti: widget.mbti,
          enneagram: widget.ennea,
          healthLevel: 'healthy',
          nameCanto: '探索者',
          tagline: '你仲喺度了解緊自己，慢慢嚟',
          encourage: '每一步都係發現',
          emoji: '🧠',
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ─── Celebration header ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🎉 結果出嚟啦！',
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cta,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── Naming card (name + emoji + type tag) ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cta.withValues(alpha: 0.85),
                            AppColors.cta.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cta.withValues(alpha: 0.3),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Emoji
                          Text(name.emoji,
                              style: const TextStyle(fontSize: 72)),
                          const SizedBox(height: 16),

                          // Name
                          Text(
                            name.nameCanto,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSerifTc(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              '${widget.mbti} · ${widget.ennea}',
                              style: GoogleFonts.notoSansTc(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Tagline
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '「${name.tagline}」',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSerifTc(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Encourage message ───
                    if (name.encourage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('💜',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name.encourage,
                                style: GoogleFonts.notoSansTc(
                                  fontSize: 13,
                                  color: AppColors.purple,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ─── Tagline selection ───
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '揀一句最代表你嘅 tagline：',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(4, (i) {
                      final taglines = [
                        name.tagline,
                        _taglineVariant1(name),
                        _taglineVariant2(name),
                        _taglineVariant3(name),
                      ];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedTagline = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedTagline == i
                                ? AppColors.cta.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedTagline == i
                                  ? AppColors.cta
                                  : AppColors.border,
                              width: _selectedTagline == i ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedTagline == i
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 18,
                                color: _selectedTagline == i
                                    ? AppColors.cta
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  taglines[i],
                                  style: GoogleFonts.notoSansTc(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    fontWeight: _selectedTagline == i
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // ─── Share button ───
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => ShareCard.share(context, name),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          '📤 Share 俾朋友',
                          style: GoogleFonts.notoSansTc(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Notification prompt ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.mustard.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('🔔',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '想每日收到一句鼓勵？',
                                      style: GoogleFonts.notoSansTc(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '我哋會喺每日早上 8 點推送語句俾你',
                                      style: GoogleFonts.notoSansTc(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.cta,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: GoogleFonts.notoSansTc(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('好呀，通知我'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Continue button ───
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: GoogleFonts.notoSansTc(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('開始使用型得你'),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _retakeTest,
                      child: Text(
                        '再測一次',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Generate tagline variants based on MBTI × Enneagram
  String _taglineVariant1(PersonalityName name) {
    if (widget.mbti.startsWith('E')) {
      return '你嘅能量可以感染成個場';
    }
    return '你嘅內心世界比你想像中豐富';
  }

  String _taglineVariant2(PersonalityName name) {
    final type = int.tryParse(widget.ennea.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
    if (type <= 3) return '你值得被錫，唔好成日淨係付出';
    if (type <= 6) return '你嘅思考係力量，但都要行動';
    return '你嘅堅強係保護，但都可以脆弱';
  }

  String _taglineVariant3(PersonalityName name) {
    if (widget.mbti.contains('N')) {
      return '你睇到嘅可能性係天賦, 信自己多啲';
    }
    return '你嘅實在係定海神針, 身邊人有你真好';
  }

  void _onContinue() {
    // Save the selected tagline preference
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selected_tagline', _selectedTagline.toString());
      // Save v2 enhanced data
      try {
        prefs.setDouble('mbti_confidence', widget.engine.state.mbtiConfidence.toDouble());
        prefs.setDouble('ennea_confidence', widget.engine.state.enneaConfidence.toDouble());
        prefs.setBool('mbti_verified', widget.engine.state.mbtiVerified);
        prefs.setBool('ennea_verified', widget.engine.state.enneaVerified);
        prefs.setInt('total_questions', widget.engine.answeredCount);
        prefs.setString('mbti_result', widget.engine.state.mbtiString);
        prefs.setString('ennea_result', widget.engine.state.enneagramKey);
      } catch (_) {
        // Non-critical — fallback to basic save
      }
    });
    widget.onComplete(widget.mbti, widget.ennea);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _retakeTest() {
    widget.engine.reset();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('test_done', false);
      prefs.remove('mbti');
      prefs.remove('ennea');
    });
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
