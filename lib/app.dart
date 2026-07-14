import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'features/daily_quote/quote_screen.dart';
import 'features/mood_checkin/mood_screen.dart';
import 'features/personality_naming/naming_screen.dart';
import 'features/profile/profile_screen.dart';

class TypingSelfApp extends StatelessWidget {
  const TypingSelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '型得你',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  final _tabs = const [
    (icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, label: '今日語句'),
    (icon: Icons.mood_outlined, activeIcon: Icons.mood, label: '今日點'),
    (icon: Icons.psychology_outlined, activeIcon: Icons.psychology, label: '型得你'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: '我'),
  ];

  final _pages = const [
    QuoteScreen(),
    MoodScreen(),
    NamingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final t = _tabs[i];
                final active = _tab == i;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? t.activeIcon : t.icon,
                          size: 20,
                          color: active ? AppColors.primary : AppColors.textMuted,
                        ),
                        if (active) ...[
                          const SizedBox(width: 6),
                          Text(t.label, style: GoogleFonts.notoSansHk(
                            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary,
                          )),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
