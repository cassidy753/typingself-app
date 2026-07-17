import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/fixed_frame.dart';
import 'features/splash/splash_screen.dart';
import 'features/daily_quote/quote_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/personality_naming/naming_engine.dart';
import 'features/assessment/assessment_intro_screen.dart';
import 'features/assessment/decision_tree_engine.dart';
import 'features/shadow_report/shadow_detector_screen.dart';
import 'features/typesoul/typesoul_screen.dart';

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
  bool _showTest = true;
  bool _showTypeSoul = false;
  bool _showShadowDetector = false;
  String? _mbti;
  String? _ennea;
  final DecisionTreeEngine _engine = DecisionTreeEngine();

  @override
  void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('test_done') ?? false;
    final mbti = prefs.getString('mbti');
    final ennea = prefs.getString('ennea');
    setState(() { _showTest = !done; _mbti = mbti; _ennea = ennea; _loading = false; });
  }

  void _onTestDone(String mbti, String ennea) {
    setState(() { _showTest = false; _showTypeSoul = true; _mbti = mbti; _ennea = ennea; });
  }

  void _onTypeSoulDone() {
    setState(() { _showTypeSoul = false; _showShadowDetector = true; });
  }

  void _onShadowDone() {
    setState(() { _showShadowDetector = false; });
  }

  void _onRetakeTest() {
    setState(() {
      _showTest = true;
      _showTypeSoul = false;
      _showShadowDetector = false;
      _mbti = null;
      _ennea = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();
    if (_showTest) {
      return AssessmentIntroScreen(
        engine: _engine,
        onComplete: _onTestDone,
      );
    }
    if (_showTypeSoul) {
      return TypeSoulScreen(
        mbti: _mbti ?? 'ENFJ',
        ennea: _ennea ?? '5w4',
        onContinue: _onTypeSoulDone,
      );
    }
    if (_showShadowDetector) {
      return ShadowDetectorScreen(
        mbti: _mbti ?? 'ENFJ',
        ennea: _ennea ?? '5w4',
        onSkip: _onShadowDone,
      );
    }
    return MainShell(mbti: _mbti ?? 'ENFJ', ennea: _ennea ?? '5w4', onRetakeTest: _onRetakeTest);
  }
}

// ──────── FLOW: Naming Celebration → Main ────────
class NamingCelebration extends StatefulWidget {
  final String mbti;
  final String ennea;
  final VoidCallback onContinue;
  const NamingCelebration({super.key, required this.mbti, required this.ennea, required this.onContinue});
  @override
  State<NamingCelebration> createState() => _NamingCelebrationState();
}

class _NamingCelebrationState extends State<NamingCelebration> {
  int _selectedTagline = 0;
  late final PersonalityName? _result;

  @override
  void initState() {
    super.initState();
    _result = NamingEngine.getName(widget.mbti, '${widget.ennea}');
    SharedPreferences.getInstance().then((p) {
      p.setBool('test_done', true);
      p.setString('mbti', widget.mbti);
      p.setString('ennea', widget.ennea);
    });
  }

  @override
  Widget build(BuildContext context) {
    PersonalityName defaultName(String mbti, String ennea) {
      return PersonalityName(
        mbti: mbti, enneagram: ennea, healthLevel: 'healthy',
        nameCanto: '探索者', tagline: '你仲喺度了解緊自己，慢慢嚟',
        encourage: '每一步都係發現', emoji: '🧠',
      );
    }
    final name = _result ?? NamingEngine.getName('ENFJ', '5w4') ?? defaultName('ENFJ', '5w4');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(name.emoji, style: const TextStyle(fontSize: 80))
                .animate()
                .scaleXY(begin: 0, end: 1, duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text(name.nameCanto, style: GoogleFonts.notoSerifTc(
                fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.cta,
              )).animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.03, duration: 300.ms),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cta.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${widget.mbti} · ${widget.ennea}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cta)),
              ).animate(delay: 400.ms).scale(duration: 400.ms),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('揀一句最代表你嘅 tagline：',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ).animate(delay: 450.ms).fadeIn(duration: 300.ms).slideX(begin: -0.02, duration: 300.ms),
              const SizedBox(height: 10),
              ...List.generate(4, (i) => GestureDetector(
                onTap: () => setState(() => _selectedTagline = i),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedTagline == i ? AppColors.cta.withValues(alpha: 0.12) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedTagline == i ? AppColors.cta : AppColors.border,
                      width: _selectedTagline == i ? 1.5 : 1,
                    ),
                  ),
                  child: Text(name.tagline, style: TextStyle(
                    fontSize: 14, color: AppColors.textPrimary,
                    fontWeight: _selectedTagline == i ? FontWeight.w600 : FontWeight.w400,
                  )),
                ),
              ).animate(delay: Duration(milliseconds: 550 + i * 150))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.03, duration: 300.ms)),
              const SizedBox(height: 24),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _share(name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        textStyle: GoogleFonts.notoSansTc(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('📤 Share 俾朋友'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text('想每日收到一句鼓勵？',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('我哋會喺每日早上 8 點推送語句俾你',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.cta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            child: const Text('好呀'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onContinue,
                    child: Text('開始使用型得你 →', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),
                ],
              ).animate(delay: 800.ms).fadeIn(duration: 500.ms),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _share(PersonalityName name) {
    final text = '''
我係 ${name.mbti} ${name.enneagram}：${name.nameCanto} ${name.emoji}

${name.tagline}

「型得你」— 了解自己，贏返自己
下載：https://xingdeni.app
''';
    Share.share(text.trim(), subject: '型得你 — 我係${name.nameCanto}');
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
                              onRetakeTest: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
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
