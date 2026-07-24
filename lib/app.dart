import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/settings_service.dart';
import 'features/home/home_screen.dart';
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
        '/home': (_) => const HomeScreen(),
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
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('mbti', mbti);
              prefs.setString('ennea', ennea);
              prefs.setBool('test_done', true);
            });
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

// ──────── TAB CONFIG ────────
class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem(this.icon, this.activeIcon, this.label);
}

// ──────── MAIN SHELL 4 (Edition 4 — Apple Books style) ────────
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

class _MainShell4State extends State<MainShell4> with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final PageController _pageCtrl;

  static const _tabs = <_TabItem>[
    _TabItem(Icons.library_books_outlined, Icons.library_books_rounded, '書架'),
    _TabItem(Icons.explore_outlined, Icons.explore_rounded, '探索'),
    _TabItem(Icons.dynamic_feed_outlined, Icons.dynamic_feed_rounded, '動態'),
    _TabItem(Icons.person_outline_rounded, Icons.person_rounded, '我'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
    if (widget.pendingFriendMbti != null && widget.pendingFriendEnnea != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCompareWithFriend();
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openCompareWithFriend() {
    if (widget.pendingFriendMbti == null || widget.pendingFriendEnnea == null) return;
    final accent = AppColors.accentDusty;
    final accentBg = AppColors.accentDusty.withValues(alpha: 0.12);
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
      widget.onThemeChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColors = [
      AppColors.accentDusty,
      AppColors.accentSage,
      AppColors.accentGold,
      AppColors.accentCoral,
    ];
    final accent = accentColors[_tab];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          // ── Thin AppBar (Apple Books style) ──
          _buildAppBar(isDark, accent),

          // ── Page content ──
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (i) => setState(() => _tab = i),
              children: [
                BookshelfScreen(key: const ValueKey('b'), mbti: widget.mbti, ennea: widget.ennea),
                ExploreGridScreen(key: const ValueKey('e'), mbti: widget.mbti, ennea: widget.ennea, onRetakeTest: widget.onRetakeTest),
                FeedScreen(key: const ValueKey('f'), mbti: widget.mbti, ennea: widget.ennea),
                ProfileV2Screen(key: const ValueKey('p'), mbti: widget.mbti, ennea: widget.ennea,
                  onRetakeTest: widget.onRetakeTest, onThemeChanged: widget.onThemeChanged),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark, accent),
    );
  }

  Widget _buildAppBar(bool isDark, Color accent) {
    final tabLabels = ['書架', '探索', '動態', '我'];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text('TS',
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('型得你',
                      style: GoogleFonts.notoSerifTc(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Tab label
                Text(tabLabels[_tab],
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(4, (i) {
              final active = _tab == i;
              final t = _tabs[i];
              return Expanded(
                child: Semantics(
                  label: t.label,
                  button: true,
                  selected: active,
                  child: GestureDetector(
                    onTap: () {
                      if (_tab == i) return;
                      setState(() => _tab = i);
                      _pageCtrl.animateToPage(i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Active indicator dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: active ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Icon
                        Icon(
                          active ? t.activeIcon : t.icon,
                          size: 22,
                          color: active
                              ? accent
                              : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        // Label
                        Text(t.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active
                                ? accent
                                : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
