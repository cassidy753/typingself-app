// ═══════════════════════════════════════════════════════════════════════
// SettingsScreen — 設定頁 (accessed from top-right gear icon)
// Daebi palette · HK Cantonese tone
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../daily_quote/zodiac_service.dart';

class SettingsScreen extends StatefulWidget {
  final Color accent;
  final Color accentBg;
  final String? mbti;
  final String? ennea;
  final VoidCallback? onRetakeTest;

  const SettingsScreen({
    super.key,
    required this.accent,
    required this.accentBg,
    this.mbti,
    this.ennea,
    this.onRetakeTest,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    if (!_loaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: widget.accent.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: widget.accent.withValues(alpha: 0.2)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('設定', style: GoogleFonts.notoSerifTc(
                      fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── 我嘅類型 ──
            _sectionHeader('🎭 我嘅類型', widget.accent),
            const SizedBox(height: 8),
            if (widget.mbti != null && widget.ennea != null)
              _TypeCard(mbti: widget.mbti!, ennea: widget.ennea!, accent: widget.accent)
            else
              _NoTestCard(accent: widget.accent),
            const SizedBox(height: 16),

            // ── 設定 ──
            _sectionHeader('⚙️ 設定', widget.accent),
            const SizedBox(height: 8),
            _SettingsContent(
              consented: _consented,
              zodiac: _zodiac,
              accent: widget.accent,
              accentBg: widget.accentBg,
              onConsentChanged: () => _showConsentDialog(),
              onZodiacChanged: _setZodiac,
              onRetakeTest: widget.onRetakeTest,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, Color accent) {
    return Text(text, style: GoogleFonts.notoSerifTc(
      fontSize: 14, fontWeight: FontWeight.w700, color: accent,
    ));
  }

  void _showConsentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('資料使用同意', style: GoogleFonts.notoSansTc(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text('我哋會用你嘅資料嚟提供個人化語句同分析。你嘅資料唔會分享俾第三方。',
          style: GoogleFonts.notoSansTc(fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              SharedPreferences.getInstance().then((p) => p.setBool('consent_given', true));
              setState(() => _consented = true);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('同意'),
          ),
        ],
      ),
    );
  }
}

// ── Type Card ──
class _TypeCard extends StatelessWidget {
  final String mbti, ennea;
  final Color accent;
  const _TypeCard({required this.mbti, required this.ennea, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🧠', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$mbti · $ennea', style: GoogleFonts.notoSansTc(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
              const SizedBox(height: 2),
              Text('已完成測試', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── No Test Card ──
class _NoTestCard extends StatelessWidget {
  final Color accent;
  const _NoTestCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🧪', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('你未完成測驗', style: GoogleFonts.notoSansTc(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                const SizedBox(height: 2),
                Text('完成測驗以解鎖個人化設定', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Content ──
class _SettingsContent extends StatelessWidget {
  final bool consented;
  final String? zodiac;
  final Color accent, accentBg;
  final VoidCallback onConsentChanged;
  final ValueChanged<String> onZodiacChanged;
  final VoidCallback? onRetakeTest;

  const _SettingsContent({
    required this.consented,
    required this.zodiac,
    required this.accent,
    required this.accentBg,
    required this.onConsentChanged,
    required this.onZodiacChanged,
    this.onRetakeTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zodiac setting
          Text('我嘅星座', style: GoogleFonts.notoSansTc(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: zodiac,
              isExpanded: true,
              hint: Text('揀你嘅太陽星座…', style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textMuted)),
              items: ZodiacService.signs.map((s) => DropdownMenuItem(
                value: s,
                child: Text('${ZodiacService.signEmoji[s] ?? ''} $s',
                  style: GoogleFonts.notoSansTc(fontSize: 14)),
              )).toList(),
              onChanged: (v) { if (v != null) onZodiacChanged(v); },
            ),
          ),
          if (zodiac != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('${ZodiacService.signEmoji[zodiac]} ', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$zodiac · ${ZodiacService.signTraits[zodiac]?['element'] ?? ''}象',
                          style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
                        Text('守護星：${ZodiacService.signTraits[zodiac]?['planet'] ?? ''}',
                          style: GoogleFonts.notoSansTc(fontSize: 12, color: accent.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 24),

          // Consent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('資料使用同意', style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('用於個人化語句同分析', style: GoogleFonts.notoSansTc(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              Switch(
                value: consented,
                onChanged: (_) => onConsentChanged(),
                activeColor: accent,
              ),
            ],
          ),

          const Divider(height: 16),

          _SettingsItem(Icons.download_outlined, '下載我的資料', () {}),
          const SizedBox(height: 4),
          _SettingsItem(Icons.delete_outline, '刪除帳戶', () {}, color: Colors.redAccent),
          const SizedBox(height: 4),
          _SettingsItem(Icons.description_outlined, '私隱政策', () {}),
          const SizedBox(height: 4),
          _SettingsItem(Icons.info_outline, '版本 1.0.0', () {}),

          const Divider(height: 16),

          // Retake test
          if (onRetakeTest != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetakeTest,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text('重新測試', style: GoogleFonts.notoSansTc(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cta,
                  side: BorderSide(color: AppColors.cta.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _SettingsItem(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: GoogleFonts.notoSansTc(fontSize: 13, color: color ?? AppColors.textPrimary)),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
