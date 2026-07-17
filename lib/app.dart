import 'package:flutter/material.dart';
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
import 'features/compare/compare_screen.dart';

// main() is in main.dart — runs ProviderScope + TypingselfApp.

class TypingselfApp extends StatefulWidget {
  const TypingselfApp({super.key});
  @override
  State<TypingselfApp> createState() => _TypingselfAppState();
}

class _TypingselfAppState extends State<TypingselfApp> {
  bool _darkMode = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _loaded = true;
    });
  }

  /// Re-check dark mode (called when returning from settings)
  void _refreshTheme() {
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      // Show splash immediately — theme will snap once loaded
      return MaterialApp(
        title: 'Typingself | 型得你',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      );
    }

    return MaterialApp(
      title: '型得你 — Typingself',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/home': (_) => FixedFrame(child: AppRoot(onThemeChanged: _refreshTheme)),
      },
    );
  }
}

class AppRoot extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  const AppRoot({super.key, this.onThemeChanged});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _loading = true;
  String? _mbti;
  String? _ennea;
  String? _pendingFriendMbti;
  String? _pendingFriendEnnea;
  String? _pendingFriendName;

  @override
  void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final mbti = prefs.getString('mbti');
    final ennea = prefs.getString('ennea');
    
    // Check for deep link parameters (e.g. ?type=INTJ-5_4&name=戰略家)
    final queryParams = Uri.base.queryParameters;
    final typeParam = queryParams['type'];
    if (typeParam != null) {
      final decoded = Uri.decodeComponent(typeParam);
      final parts = decoded.split('-');
      if (parts.length == 2) {
        _pendingFriendMbti = parts[0].toUpperCase();
        _pendingFriendEnnea = parts[1].replaceAll('_', 'w');
        _pendingFriendName = queryParams['name'] != null
            ? Uri.decodeComponent(queryParams['name']!)
            : null;
      }
    }
    
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
    return MainShell(
      mbti: _mbti ?? 'ENFJ',
      ennea: _ennea ?? '5w4',
      onRetakeTest: _onRetakeTest,
      onThemeChanged: widget.onThemeChanged,
      pendingFriendMbti: _pendingFriendMbti,
      pendingFriendEnnea: _pendingFriendEnnea,
      pendingFriendName: _pendingFriendName,
    );
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
  final VoidCallback? onThemeChanged;
  final String? pendingFriendMbti;
  final String? pendingFriendEnnea;
  final String? pendingFriendName;
  const MainShell({super.key, required this.mbti, required this.ennea, this.onRetakeTest, this.onThemeChanged, this.pendingFriendMbti, this.pendingFriendEnnea, this.pendingFriendName});
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
  void initState() {
    super.initState();
    // Handle deep link navigation after first frame
    if (widget.pendingFriendMbti != null && widget.pendingFriendEnnea != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCompareWithFriend();
      });
    }
  }

  /// Open compare screen with a friend's type from a deep link
  void _openCompareWithFriend() {
    if (widget.pendingFriendMbti == null || widget.pendingFriendEnnea == null) return;
    final accent = AppColors.purple;
    final accentBg = Color(0x209B72AA);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompareScreen(
          myMbti: widget.mbti,
          myEnnea: widget.ennea,
          accent: accent,
          accentBg: accentBg,
          initialFriendMbti: widget.pendingFriendMbti,
          initialFriendEnnea: widget.pendingFriendEnnea,
          initialFriendName: widget.pendingFriendName,
        ),
      ),
    );
  }

  /// Navigate to settings with dark mode change callback.
  void _openSettings(Color accent, Color accentBg) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          accent: accent,
          accentBg: accentBg,
          mbti: widget.mbti,
          ennea: widget.ennea,
          onRetakeTest: widget.onRetakeTest,
        ),
      ),
    ).then((_) {
      // When coming back from settings, refresh theme
      widget.onThemeChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = _tabs[_tab];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Dynamic background color based on theme
    final bgColor = isDark
        ? Color.lerp(AppColors.darkBackground, t.accent, 0.08) ?? AppColors.darkBackground
        : Color.lerp(AppColors.background, t.accent, 0.15) ?? AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? t.accent.withValues(alpha: 0.05)
                  : t.accent.withValues(alpha: 0.08),
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
                          child: Semantics(
                            label: 'Typingself',
                            child: Text('TS', style: GoogleFonts.notoSerifTc(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.purple,
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Typingself | 型得你・人格成長', style: GoogleFonts.notoSerifTc(fontSize: 16, fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                    ]),
                    Semantics(
                      label: '設定',
                      button: true,
                      child: GestureDetector(
                        onTap: () => _openSettings(t.accent, t.accentBg),
                        child: Container(
                          width: 44, height: 44,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                          child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 16))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: reduceMotion
          ? _buildScreen()
          : AnimatedSwitcher(
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
          color: isDark ? AppColors.darkSurface : AppColors.surface,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: t.label,
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          decoration: BoxDecoration(
            color: active ? t.accentBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(fontSize: active ? 22 : 20, color: active ? t.accent : (isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                child: Text(t.icon),
              ),
              const SizedBox(height: 3),
              Text(t.label, style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? t.accent : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
