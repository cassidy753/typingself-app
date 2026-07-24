import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _tabs = [
    _TabData('藏書', Icons.auto_stories_rounded),
    _TabData('尋索', Icons.search_rounded),
    _TabData('足跡', Icons.book_rounded),
    _TabData('心', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tab,
        children: const [
          _TabHome(),
          _TabLibrary(),
          _TabSaved(),
          _TabProfile(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final t = _tabs[i];
                final active = _tab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 22, color: active ? AppColors.primary : AppColors.textMuted),
                        const SizedBox(height: 2),
                        Text(t.label, style: GoogleFonts.notoSansTc(fontSize: 10, color: active ? AppColors.primary : AppColors.textMuted, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
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

class _TabData {
  final String label;
  final IconData icon;
  const _TabData(this.label, this.icon);
}

// ─── TAB 1: 藏書（Home）───
class _TabHome extends StatelessWidget {
  const _TabHome();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 心靈雞湯
            Text('今日金句', style: GoogleFonts.notoSansTc(fontSize: 10, letterSpacing: 0.2, color: AppColors.gold, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text('「認識你自己，是一切智慧嘅開端。」', style: GoogleFonts.notoSerifTc(fontSize: 16, height: 1.6, color: AppColors.textPrimary), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _iconBtn(Icons.share_rounded),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.bookmark_border_rounded),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Type + Avatar
            Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('ENFJ', style: GoogleFonts.notoSansTc(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('教育家', style: GoogleFonts.notoSerifTc(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('ENFJ · 5w4', style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
            ]),
            const SizedBox(height: 24),

            // 3 quotes to specific typingself
            Text('你嘅型格語錄', style: GoogleFonts.notoSansTc(fontSize: 10, letterSpacing: 0.2, color: AppColors.gold, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _quoteCard('用溫暖改變世界，係你嘅使命。'),
            _quoteCard('直覺係你最大嘅武器，信佢。'),
            _quoteCard('你唔需要改變自己，你需要成為自己。'),
            const SizedBox(height: 24),

            // 星座運勢
            Text('今日星座運勢', style: GoogleFonts.notoSansTc(fontSize: 10, letterSpacing: 0.2, color: AppColors.gold, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(children: [
                Text('♌️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Text('今日獅子座：你嘅直覺會帶你去啱嘅方向。耳朵要打開。', style: GoogleFonts.notoSerifTc(fontSize: 13, height: 1.5, color: AppColors.textSecondary))),
                const SizedBox(width: 8),
                Icon(Icons.share_rounded, size: 16, color: AppColors.textMuted),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) => GestureDetector(
    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.gap, borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 14, color: AppColors.textMuted)),
  );

  Widget _quoteCard(String q) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        Expanded(child: Text(q, style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textPrimary))),
        Icon(Icons.share_rounded, size: 14, color: AppColors.textMuted),
      ]),
    ),
  );
}

// ─── TAB 2: Library ───
class _TabLibrary extends StatelessWidget {
  const _TabLibrary();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Center(
      child: Text('尋索', style: GoogleFonts.notoSerifTc(fontSize: 18, color: AppColors.textMuted)),
    ));
  }
}

// ─── TAB 3: Saved ───
class _TabSaved extends StatelessWidget {
  const _TabSaved();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Center(
      child: Text('足跡', style: GoogleFonts.notoSerifTc(fontSize: 18, color: AppColors.textMuted)),
    ));
  }
}

// ─── TAB 4: Profile ───
class _TabProfile extends StatelessWidget {
  const _TabProfile();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Center(
      child: Text('心', style: GoogleFonts.notoSerifTc(fontSize: 18, color: AppColors.textMuted)),
    ));
  }
}
