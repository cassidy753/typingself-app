import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'features/daily_quote/quote_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/my_type/my_type_screen.dart';
import 'features/support/support_screen.dart';
import 'features/personality_naming/naming_engine.dart';

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

class FixedFrame extends StatelessWidget {
  final Widget child;
  const FixedFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth > 420) {
        return Scaffold(
          backgroundColor: const Color(0xFF3A2C22),
          body: Center(child: SizedBox(width: 390, height: c.maxHeight, child: child)),
        );
      }
      return child;
    });
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
  String? _mbti;
  String? _ennea;

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
    setState(() { _showTest = false; _mbti = mbti; _ennea = ennea; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();
    if (_showTest) return FirstTestFlow(onDone: _onTestDone);
    return MainShell(mbti: _mbti ?? 'ENFJ', ennea: _ennea ?? '5w4');
  }
}

// ──────── FLOW: Test → Celebration → Main ────────
class FirstTestFlow extends StatefulWidget {
  final void Function(String mbti, String ennea) onDone;
  const FirstTestFlow({super.key, required this.onDone});
  @override
  State<FirstTestFlow> createState() => _FirstTestFlowState();
}

class _FirstTestFlowState extends State<FirstTestFlow> {
  int _q = 0;
  String _result = '';
  int _e = 0, _i = 0, _s = 0, _n = 0, _t = 0, _f = 0, _j = 0, _p = 0;

  static const _questions = [
    ['朋友傷心嗰陣，你會…', ['即刻去安慰佢', '靜靜陪喺身邊', '幫佢分析問題', '分享自己經歷'], [2,0,1,1]],  // Fe/Fi
    ['放假嗰日，你通常…', ['約人出去癲', '自己 Hea 一日', '做有意義嘅事', '計劃下星期'], [2,0,1,1]], // E/I
    ['做決定靠咩？', ['直覺', '數據分析', '朋友意見', '求其啦'], [1,0,2,0]], // T/F
    ['你覺得自己…', ['外向有 energy', '內向但豐富', '兩樣都有啲', '睇情況'], [2,1,1,0]], // E/I
    ['去旅行你會…', ['plan 到盡', '去到先算', 'plan 大方向', '跟朋友安排'], [1,0,2,1]], // J/P
    ['你朋友點形容你？', ['好有創意', '好實際', '好理性', '好感性'], [0,1,2,2]], // N/S + T/F
    ['面對壓力嗰陣…', ['搵人傾訴', '收埋自己', '分析點解決', '做嘢分散注意'], [2,0,1,1]], // Fe/Fi
    ['你記性好嘅係…', ['人臉同故事', '數字同日期', '感受同氣氛', '細節同邏輯'], [0,1,2,1]], // N/S
    ['你覺得自己係…', ['完美主義', '和平主義', '成就导向', '忠誠可靠'], [1,2,0,1]], // Enneagram proxy
    ['工作上你傾向…', ['帶領團隊', '專注執行', '分析策略', '協調溝通'], [2,0,1,1]], // Te/Ti
    ['你點睇新事物？', ['興奮想試', '小心觀察', '研究清楚先', '冇興趣'], [2,0,1,0]], // Ne/Si
    ['最後一題：你係…', ['多啲諗將來', '多啲記過去', '多啲關注當下', '多啲分析規律'], [0,1,2,0]], // N/S
  ];

  void _answer(int optIdx) {
    final scores = _questions[_q][2] as List<int>;
    final val = scores[optIdx];
    // Simplified: route scores to dimensions based on question index
    if (_q == 0 || _q == 6) { if (val > 0) _f += val; else _t += 1; }
    else if (_q == 1 || _q == 3) { if (val > 0) _e += val; else _i += 1; }
    else if (_q == 2) { if (val > 1) _f += val; else _t += val; }
    else if (_q == 4) { if (val > 0) _j += val; else _p += 1; }
    else if (_q == 5 || _q == 7) { if (val > 1) _s += val; else _n += val; }
    else if (_q == 8) { /* enneagram-ish */ }
    else if (_q == 9) { if (val > 0) _t += val; else _f += 1; }
    else if (_q == 10 || _q == 11) { if (val > 0) _n += val; else _s += 1; }

    if (_q < _questions.length - 1) {
      setState(() => _q++);
    } else {
      setState(() {});
      _finish();
    }
  }

  void _finish() {
    final mbti = '${_e>=_i?"E":"I"}${_s>=_n?"S":"N"}${_t>=_f?"T":"F"}${_j>=_p?"J":"P"}';
    final ennea = '5w4';
    widget.onDone(mbti, ennea);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_q][0] as String;
    final opts = _questions[_q][1] as List<String>;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  GestureDetector(
                    onTap: _q > 0 ? () => setState(() => _q--) : null,
                    child: Text('‹', style: TextStyle(fontSize: 24, color: _q > 0 ? AppColors.textPrimary : AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('問題 ${_q+1} / ${_questions.length}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_q + 1) / _questions.length,
                            child: Container(decoration: BoxDecoration(color: AppColors.cta, borderRadius: BorderRadius.circular(3))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(q, textAlign: TextAlign.center,
                style: GoogleFonts.notoSerifTc(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.6)),
              const SizedBox(height: 28),
              ...opts.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _answer(opts.indexOf(opt)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: AppColors.border),
                      ),
                      textStyle: GoogleFonts.notoSansTc(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    child: Align(alignment: Alignment.centerLeft, child: Text(opt)),
                  ),
                ),
              )),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: Text('是但啦，略過 →', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ),
                  Text('${_q+1}/${_questions.length}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────── NAMING CELEBRATION ────────
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
    // Save test result
    SharedPreferences.getInstance().then((p) {
      p.setBool('test_done', true);
      p.setString('mbti', widget.mbti);
      p.setString('ennea', widget.ennea);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safe fallback if name lookup fails
    PersonalityName defaultName(String mbti, String ennea) {
      return PersonalityName(
        mbti: mbti, enneagram: ennea, healthLevel: 'healthy',
        nameCanto: '探索者', tagline: '你仲喺度了解緊自己，慢慢嚟',
        encourage: '每一步都係發現', emoji: '🧠',
      );
    }
    final name = _result ?? NamingEngine.getName('ENFJ', '5') ?? defaultName('ENFJ', '5');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Emoji
              Text(name.emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 12),
              // Name
              Text(name.nameCanto, style: GoogleFonts.notoSerifTc(
                fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.cta,
              )),
              const SizedBox(height: 8),
              // Type tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cta.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${widget.mbti} · ${widget.ennea}w${widget.ennea}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cta)),
              ),
              const SizedBox(height: 24),
              // Tagline selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text('揀一句最代表你嘅 tagline：',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
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
              )),
              const SizedBox(height: 24),
              // Share button
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
              // Notification prompt
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
              // Skip / Continue
              TextButton(
                onPressed: widget.onContinue,
                child: Text('開始使用型得你 →', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _share(PersonalityName name) {
    // Placeholder: would open native share sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📤 Share card: ${name.nameCanto} — ${name.tagline}')),
    );
  }
}

// ──────── TAB CONFIG ────────
class _Tab {
  final String icon, label;
  final Color accent, accentBg;
  const _Tab(this.icon, this.label, this.accent, this.accentBg);
}

// ──────── MAIN SHELL ────────
class MainShell extends StatefulWidget {
  final String mbti;
  final String ennea;
  const MainShell({super.key, required this.mbti, required this.ennea});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  bool _showCelebration = true;

  static const _tabs = <_Tab>[
    _Tab('🌤️', '今日',  Color(0xFF9B72AA), Color(0x209B72AA)),
    _Tab('🔎', '發掘',  Color(0xFFD4A843), Color(0x20D4A843)),
    _Tab('🎭', '我個型', Color(0xFFE0785A), Color(0x20E0785A)),
    _Tab('💖', '支持',  Color(0xFF8FA87A), Color(0x208FA87A)),
  ];

  @override
  Widget build(BuildContext context) {
    // Show naming celebration first
    if (_showCelebration) {
      return NamingCelebration(
        mbti: widget.mbti,
        ennea: widget.ennea,
        onContinue: () => setState(() => _showCelebration = false),
      );
    }

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
                        decoration: BoxDecoration(color: t.accentBg, borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('🧠', style: TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 6),
                      Text('型得你', style: GoogleFonts.notoSerifTc(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    ]),
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface, borderRadius: BorderRadius.circular(10),
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
              children: List.generate(4, (i) => _navItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
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
