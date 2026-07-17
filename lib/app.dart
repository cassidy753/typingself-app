import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/fixed_frame.dart';
import 'features/splash/splash_screen.dart';
import 'features/daily_quote/quote_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/assessment/assessment_intro_screen.dart';
import 'features/assessment/decision_tree_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TypingselfApp()));
}

class TypingselfApp extends StatelessWidget {
  const TypingselfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typingself | 型得你',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const FixedFrame(child: AppRoot()),
      },
    );
  }
}

// ──────── APP ROOT ────────
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _loading = true;
  String? _mbti;
  String? _ennea;

  @override
  void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final mbti = prefs.getString('mbti');
    final ennea = prefs.getString('ennea');
    setState(() { _mbti = mbti; _ennea = ennea; _loading = false; });
  }

  void _onRetakeTest() {
    // Clear old results before starting fresh assessment
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('mbti');
      prefs.remove('ennea');
      prefs.remove('test_done');
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssessmentIntroScreen(
          engine: DecisionTreeEngine(),
          onComplete: (mbti, ennea) {
            // Save new results
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('mbti', mbti);
              prefs.setString('ennea', ennea);
              prefs.setBool('test_done', true);
            });
            // Pop back and refresh state
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              _check();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();
    return MainShell(mbti: _mbti ?? 'ENFJ', ennea: _ennea ?? '5w4', onRetakeTest: _onRetakeTest);
  }
}


// ──────── 3-TAB CONFIG ────────
class _Tab {
  final String icon, label;
  final Color accent, accentBg;
  const _Tab(this.icon, this.label, this.accent, this.accentBg);
}

// ──────── MAIN SHELL ────────
class MainShell extends StatefulWidget {
  final String mbti;
  final String ennea;
  final VoidCallback? onRetakeTest;
  const MainShell({super.key, required this.mbti, required this.ennea, this.onRetakeTest});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _tabs = <_Tab>[
    _Tab('🏠', '首頁',  Color(0xFF9B72AA), Color(0x209B72AA)),  // Purple
    _Tab('🔍', '發掘',  Color(0xFFD4A843), Color(0x20D4A843)),  // Mustard
    _Tab('👤', '我嘅',  Color(0xFFE0785A), Color(0x20E0785A)),  // Coral
  ];

  @override
  Widget build(BuildContext context) {
    final t = _tabs[_tab];
    return Scaffold(
      backgroundColor: Color.lerp(AppColors.background, t.accent, 0.15) ?? AppColors.background,
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
                          color: AppColors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('TS', style: GoogleFonts.notoSerifTc(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.purple,
                          )),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Typingself | 型得你・人格成長', style: GoogleFonts.notoSerifTc(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    ]),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                              accent: t.accent,
                              accentBg: t.accentBg,
                              mbti: widget.mbti,
                              ennea: widget.ennea,
                              onRetakeTest: widget.onRetakeTest,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surface, borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 16))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _buildScreen(),
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
              children: List.generate(3, (i) => _navItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    final t = _tabs[_tab];
    switch (_tab) {
      case 0: return QuoteScreen(key: const ValueKey('q'), accent: t.accent, accentBg: t.accentBg, mbti: widget.mbti, ennea: widget.ennea);
      case 1: return ExploreScreen(key: const ValueKey('k'), accent: t.accent, accentBg: t.accentBg, mbti: widget.mbti, ennea: widget.ennea, onRetakeTest: widget.onRetakeTest);
      case 2: return ProfileScreen(key: const ValueKey('p'), accent: t.accent, accentBg: t.accentBg, mbti: widget.mbti, ennea: widget.ennea);
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
