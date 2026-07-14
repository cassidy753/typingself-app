import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

/// First-launch consent screen (PDPO compliance)
class ConsentScreen extends StatefulWidget {
  final VoidCallback onConsentGiven;
  const ConsentScreen({super.key, required this.onConsentGiven});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;

  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consent_given', true);
    widget.onConsentGiven();
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consent_given', false); // local-only mode
    widget.onConsentGiven();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.purpleLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.shield_outlined, size: 40, color: AppTheme.purple),
              ),
              const SizedBox(height: 24),

              Text('你嘅私隱，我哋重視',
                style: GoogleFonts.notoSerifHk(
                  fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimary,
                )),
              const SizedBox(height: 12),

              Text('型得你收集以下資料：',
                style: GoogleFonts.notoSansHk(
                  fontSize: 15, color: AppTheme.textSecondary,
                )),
              const SizedBox(height: 16),

              _bullet('你嘅人格測試結果'),
              _bullet('每日心情記錄'),
              _bullet('裝置 token（用於每日推送）'),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.purpleLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: AppTheme.purple, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '我哋唔會賣你嘅數據。你可以隨時刪除帳戶及所有資料。',
                        style: GoogleFonts.notoSansHk(
                          fontSize: 13, color: AppTheme.purple, height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Agree checkbox
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                title: Text('我同意收集以上資料作個人化用途',
                  style: GoogleFonts.notoSansHk(fontSize: 14, color: AppTheme.textPrimary)),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 16),

              // Accept button
              SizedBox(
                width: double.infinity, height: 52,
                child: FilledButton(
                  onPressed: _agreed ? _accept : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('同意並開始使用',
                    style: GoogleFonts.notoSansHk(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),

              // Skip (local-only)
              TextButton(
                onPressed: _skip,
                child: Text('暫時唔用住（每日語句 + mood 仍可用）',
                  style: GoogleFonts.notoSansHk(fontSize: 12, color: AppTheme.textMuted)),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Icon(Icons.check_circle, size: 16, color: AppTheme.purple.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.notoSansHk(
            fontSize: 14, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
