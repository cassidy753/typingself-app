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

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  final _pages = const [
    QuoteScreen(), ExploreScreen(), MyTypeScreen(), SupportScreen(),
  ];

  static const _tabs = [
    ('🌤️', '今日'),
    ('🔎', '發掘'),
    ('🎭', '我個型'),
    ('💖', '支持'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
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
                          color: AppColors.surface,
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_tab],
      ),
      // Bottom nav: pill style, no hard line, subtle shadow
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

  Widget _navItem(int i) {
    final active = _tab == i;
    final (icon, label) = _tabs[i];
    return GestureDetector(
      onTap: () => setState(() => _tab = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: active ? 22 : 20,
                color: active ? AppColors.cta : AppColors.textMuted,
              ),
              child: Text(icon),
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppColors.textPrimary : AppColors.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}
