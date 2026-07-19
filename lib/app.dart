import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/settings_service.dart';
import 'core/fixed_frame.dart';
import 'features/splash/splash_screen.dart';
import 'features/bookshelf/bookshelf_screen.dart';
import 'features/explore_v2/explore_grid_screen.dart';
import 'features/feed/feed_screen.dart';
import 'features/profile_v2/profile_v2_screen.dart';
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
    await SettingsService().init();
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
    return MainShell4(
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


// ──────── 4-TAB CONFIG ────────
class _Tab4 {
  final String icon, label;
  final Color accent, accentBg;
  const _Tab4(this.icon, this.label, this.accent, this.accentBg);
}

// ──────── MAIN SHELL (4 tabs) ────────
class MainShell4 extends StatefulWidget {
  final String mbti;
  final String ennea;
  final VoidCallback? onRetakeTest;
  final VoidCallback? onThemeChanged;
  final String? pendingFriendMbti;
  final String? pendingFriendEnnea;
  final String? pendingFriendName;
  const MainShell4({super.key, required this.mbti, required this.ennea, this.onRetakeTest, this.onThemeChanged, this.pendingFriendMbti, this.pendingFriendEnnea, this.pendingFriendName});
  @override
  State<MainShell4> createState() => _MainShell4State();
}

class _MainShell4State extends State<MainShell4> {
  int _tab = 0;

  static const _tabs = <_Tab4>[
    _Tab4('📚', '書架', Color(0xFF9B72AA), Color(0x209B72AA)),  // Purple
    _Tab4('🔍', '探索', Color(0xFFD4A843), Color(0x20D4A843)),  // Mustard
    _Tab4('💬', '動態', Color(0xFF8FA87A), Color(0x208FA87A)),  // Sage
    _Tab4('👤', '我',   Color(0xFFE0785A), Color(0x20E0785A)),  // Coral
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
        : Color.lerp(AppColors.background, t.accent, 0.12) ?? AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? t.accent.withValues(alpha: 0.05)
                  : t.accent.withValues(alpha: 0.06),
              border: Border(bottom: BorderSide(color: t.accent.withValues(alpha: 0.15))),
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
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Semantics(
                            label: 'Typingself',
                            child: Text('TS', style: GoogleFonts.notoSerifTc(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.purple,
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Typingself | 型得你', style: GoogleFonts.notoSerifTc(fontSize: 15, fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                    ]),
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
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) => _navItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_tab) {
      case 0:
        return BookshelfScreen(key: const ValueKey('b'), mbti: widget.mbti, ennea: widget.ennea);
      case 1:
        return ExploreGridScreen(key: const ValueKey('e'), mbti: widget.mbti, ennea: widget.ennea, onRetakeTest: widget.onRetakeTest);
      case 2:
        return FeedScreen(key: const ValueKey('f'), mbti: widget.mbti, ennea: widget.ennea);
      case 3:
        return ProfileV2Screen(key: const ValueKey('p'), mbti: widget.mbti, ennea: widget.ennea,
          onRetakeTest: widget.onRetakeTest, onThemeChanged: widget.onThemeChanged);
      default:
        return const SizedBox();
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          decoration: BoxDecoration(
            color: active ? t.accentBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(fontSize: active ? 22 : 20, color: active ? t.accent : (isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                child: Text(t.icon),
              ),
              const SizedBox(height: 2),
              Text(t.label, style: TextStyle(
                fontSize: 11,
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
