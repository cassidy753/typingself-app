import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../daily_quote/zodiac_service.dart';
import 'consent_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _consented = false;
  String? _zodiac;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _consented = prefs.getBool('consent_given') ?? false;
      _zodiac = prefs.getString('zodiac_sign');
      _loaded = true;
    });
  }

  Future<void> _setZodiac(String sign) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zodiac_sign', sign);
    setState(() => _zodiac = sign);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_consented) {
      return ConsentScreen(onConsentGiven: () {
        setState(() => _consented = true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.purpleLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: AppTheme.purple, size: 18),
            ),
            const SizedBox(width: 10),
            Text('我', style: GoogleFonts.notoSerifHk(
              fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary,
            )),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.purpleLight,
                  child: const Icon(Icons.person, size: 36, color: AppTheme.purple),
                ),
                const SizedBox(height: 12),
                Text('未登入', style: GoogleFonts.notoSansHk(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('登入後 sync 資料 + 解鎖付費功能',
                  style: GoogleFonts.notoSansHk(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: FilledButton.icon(
                    onPressed: () {}, // TODO: Auth
                    icon: const Icon(Icons.login, size: 18),
                    label: Text('登入 / 註冊',
                      style: GoogleFonts.notoSansHk(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 18),
                    label: Text('用 Google 繼續',
                      style: GoogleFonts.notoSansHk(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Zodiac preference
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('我嘅星座', style: GoogleFonts.notoSansHk(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _zodiac,
                    isExpanded: true,
                    hint: Text('揀你嘅太陽星座…',
                      style: GoogleFonts.notoSansHk(fontSize: 14, color: AppTheme.textMuted)),
                    items: ZodiacService.signs.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('${ZodiacService.signEmoji[s] ?? ''} $s',
                        style: GoogleFonts.notoSansHk(fontSize: 15)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) _setZodiac(v);
                    },
                  ),
                ),
                if (_zodiac != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.purpleLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text('${ZodiacService.signEmoji[_zodiac]} ',
                          style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_zodiac ${ZodiacService.signTraits[_zodiac]?['element'] ?? ''}象',
                                style: GoogleFonts.notoSansHk(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.purple)),
                              Text('守護星：${ZodiacService.signTraits[_zodiac]?['planet'] ?? ''}',
                                style: GoogleFonts.notoSansHk(
                                  fontSize: 13, color: AppTheme.purple.withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Premium section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.purple, Color(0xFF5B21B6)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('型得你 Premium', style: GoogleFonts.notoSerifHk(
                  fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                Text('解鎖完整人格測試 + 心理健康分析 + 個人化語句',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansHk(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 16),
                _premiumRow('🧠', 'MBTI + Enneagram 完整測試'),
                _premiumRow('📊', '情景題深度心理健康分析'),
                _premiumRow('💜', '個人化每日語句（按你人格）'),
                _premiumRow('📈', '季度趨勢 dashboard'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('HK\$22 解鎖入門版',
                      style: GoogleFonts.notoSansHk(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Data & privacy
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('私隱與資料', style: GoogleFonts.notoSansHk(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                _menuItem(Icons.download_outlined, '下載我的資料', () {}),
                const Divider(height: 1),
                _menuItem(Icons.delete_outline, '刪除帳戶', () {}, color: Colors.redAccent),
                const Divider(height: 1),
                _menuItem(Icons.description_outlined, '私隱政策', () {}),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _premiumRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.notoSansHk(
          fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
      ]),
    );
  }

  Widget _menuItem(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppTheme.textSecondary, size: 20),
      title: Text(text, style: GoogleFonts.notoSansHk(
        fontSize: 14, color: color ?? AppTheme.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
      onTap: onTap,
    );
  }
}
