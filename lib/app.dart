import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      home: const MainShell(),
    );
  }
}

// Each tab gets its own accent color from the Daebi palette
class TabConfig {
  final String icon;
  final String label;
  final Color accent;    // tab accent color
  final Color accentBg;  // 15% opacity background

  const TabConfig(this.icon, this.label, this.accent, this.accentBg);
}

const _tabs = [
  TabConfig('🌤️', '今日',  Color(0xFF9B72AA), Color(0x209B72AA)), // Soft Purple
  TabConfig('🔎', '發掘',  Color(0xFFD4A843), Color(0x20D4A843)), // Warm Mustard
  TabConfig('🎭', '我個型', Color(0xFFE0785A), Color(0x20E0785A)), // Muted Coral
  TabConfig('💖', '支持',  Color(0xFF8FA87A), Color(0x208FA87A)), // Soft Sage
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(AppColors.background, _tabs[_tab].accent, 0.04)!,
      // AppBar with tab accent color tint
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              border: Border(
                bottom: BorderSide(color: _tabs[_tab].accent.withValues(alpha: 0.15)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: _tabs[_tab].accentBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('🧠', style: TextStyle(fontSize: 18))),
                        ),
                        const SizedBox(width: 6),
                        Text('型得你',
                          style: GoogleFonts.notoSerifTc(
                            fontSize: 18, fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          )),
                      ],
                    ),
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
        child: _buildScreen(_tab),
      ),
      // Bottom nav: pill style, no hard line
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
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

  Widget _buildScreen(int i) {
    // Pass the tab accent color to each screen
    switch (i) {
      case 0: return QuoteScreen(key: ValueKey('q'), accent: _tabs[0].accent, accentBg: _tabs[0].accentBg);
      case 1: return ExploreScreen(key: ValueKey('e'), accent: _tabs[1].accent, accentBg: _tabs[1].accentBg);
      case 2: return MyTypeScreen(key: ValueKey('m'), accent: _tabs[2].accent, accentBg: _tabs[2].accentBg);
      case 3: return SupportScreen(key: ValueKey('s'), accent: _tabs[3].accent, accentBg: _tabs[3].accentBg);
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
              style: TextStyle(
                fontSize: active ? 22 : 20,
                color: active ? t.accent : AppColors.textMuted,
              ),
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
