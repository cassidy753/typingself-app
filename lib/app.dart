import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'features/daily_quote/quote_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/my_type/my_type_screen.dart';
import 'features/support/support_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TypingselfApp()));
}

class TypingselfApp extends StatelessWidget {
  const TypingselfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '型得你',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const FixedFrame(child: AppRoot()),
    );
  }
}

/// Locks to 390px wide on web/desktop, full-screen on mobile.
class FixedFrame extends StatelessWidget {
  final Widget child;
  const FixedFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth > 420) {
        return Scaffold(
          backgroundColor: const Color(0xFF3A2C22),
          body: Center(
            child: SizedBox(width: 390, height: c.maxHeight, child: child),
          ),
        );
      }
      return child;
    });
  }
}

// ─── App Root: decides first-launch flow ───
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _loading = true;
  bool _showTest = true; // Default: show test on first launch

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('test_done') ?? false;
    setState(() { _showTest = !done; _loading = false; });
  }

  void _onTestDone() {
    setState(() => _showTest = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();
    if (_showTest) return FirstTestScreen(onDone: _onTestDone);
    return const MainShell();
  }
}

// ─── First-launch Test Screen ───
class FirstTestScreen extends StatefulWidget {
  final VoidCallback onDone;
  const FirstTestScreen({super.key, required this.onDone});
  @override
  State<FirstTestScreen> createState() => _FirstTestScreenState();
}

class _FirstTestScreenState extends State<FirstTestScreen> {
  int _q = 0;

  static const _questions = [
    '朋友傷心嗰陣，你會…',
    '放假嗰日，你通常…',
    '做決定嗰陣，你靠…',
    '你覺得自己係…',
  ];

  static const _options = [
    ['即刻走去安慰佢', '靜靜陪喺佢身邊', '幫佢分析問題', '分享自己經歷'],
    ['約人出去', '自己 Hea 一日', '做有意義嘅事', '計劃下星期'],
    ['直覺', '數據分析', '朋友意見', '總之是但啦'],
    ['外向又有 energy', '內向但豐富', '兩樣都有啲', '睇情況'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Progress
              Row(
                children: [
                  GestureDetector(
                    onTap: _q > 0 ? () => setState(() => _q--) : null,
                    child: Text('‹', style: TextStyle(
                      fontSize: 24, color: _q > 0 ? AppColors.textPrimary : AppColors.textMuted,
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('問題 ${_q+1} / ${_questions.length}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_q + 1) / _questions.length,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cta,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Question
              Text(
                _questions[_q],
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerifTc(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Options
              ...(_options[_q].map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _q < _questions.length - 1
                        ? () => setState(() => _q++)
                        : _finish,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: AppColors.border),
                      ),
                      textStyle: GoogleFonts.notoSansTc(
                        fontSize: 15, fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(opt),
                    ),
                  ),
                ),
              ))),
              const Spacer(),
              // Skip / Next
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: Text('是但啦，略過 →',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ),
                  Text('${_q+1}/${_questions.length}',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_done', true);
    widget.onDone();
  }
}

// ─── Tab Config ───
class _Tab {
  final String icon, label;
  final Color accent, accentBg;
  const _Tab(this.icon, this.label, this.accent, this.accentBg);
}

// ─── Main Shell ───
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _tabs = <_Tab>[
    _Tab('🌤️', '今日',  Color(0xFF9B72AA), Color(0x209B72AA)),
    _Tab('🔎', '發掘',  Color(0xFFD4A843), Color(0x20D4A843)),
    _Tab('🎭', '我個型', Color(0xFFE0785A), Color(0x20E0785A)),
    _Tab('💖', '支持',  Color(0xFF8FA87A), Color(0x208FA87A)),
  ];

  @override
  Widget build(BuildContext context) {
    final t = _tabs[_tab];
    return Scaffold(
      backgroundColor: Color.lerp(AppColors.background, t.accent, 0.15)!,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.08),
              border: Border(bottom: BorderSide(color: t.accent.withValues(alpha: 0.2))),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: t.accentBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('🧠', style: TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 6),
                      Text('型得你', style: GoogleFonts.notoSerifTc(
                        fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    ]),
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 16))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildScreen(context),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) => _navItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final t = _tabs[_tab];
    switch (_tab) {
      case 0: return QuoteScreen(key: const ValueKey('q'), accent: t.accent, accentBg: t.accentBg);
      case 1: return ExploreScreen(key: const ValueKey('e'), accent: t.accent, accentBg: t.accentBg);
      case 2: return MyTypeScreen(key: const ValueKey('m'), accent: t.accent, accentBg: t.accentBg);
      case 3: return SupportScreen(key: const ValueKey('s'), accent: t.accent, accentBg: t.accentBg);
      default: return const SizedBox();
    }
  }

  Widget _navItem(int i) {
    final active = _tab == i;
    final t = _tabs[i];
    return GestureDetector(
      onTap: () => setState(() => _tab = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? t.accentBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(fontSize: active ? 22 : 20, color: active ? t.accent : AppColors.textMuted),
              child: Text(t.icon),
            ),
            const SizedBox(height: 3),
            Text(t.label, style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? t.accent : AppColors.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}
