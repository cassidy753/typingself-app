import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _zodiac = '未設定';
  String _language = '書面粵語';
  bool _darkMode = false;
  bool _notification = true;

  final _zodiacOptions = ['未設定', '白羊', '金牛', '雙子', '巨蟹', '獅子', '處女', '天秤', '天蠍', '人馬', '山羊', '水瓶', '雙魚'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('設定個人檔案', style: GoogleFonts.notoSerifTc(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('可以隨時更改', style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              // Zodiac
              _sectionLabel('星座'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _zodiac,
                items: _zodiacOptions.map((z) => DropdownMenuItem(value: z, child: Text(z, style: GoogleFonts.notoSansTc(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _zodiac = v ?? '未設定'),
                decoration: _inputDeco(),
              ),
              const SizedBox(height: 24),

              // Language
              _sectionLabel('語言風格'),
              const SizedBox(height: 8),
              _toggleRow('書面粵語', '自然粵語', _language == '自然粵語', (v) {
                setState(() => _language = v ? '自然粵語' : '書面粵語');
              }),
              const SizedBox(height: 24),

              // Dark mode
              _sectionLabel('深色模式'),
              const SizedBox(height: 8),
              _switchRow('深色模式', _darkMode, (v) => setState(() => _darkMode = v)),
              const SizedBox(height: 24),

              // Notification
              _sectionLabel('通知'),
              const SizedBox(height: 8),
              _switchRow('每日金句通知', _notification, (v) => setState(() => _notification = v)),
              const SizedBox(height: 48),

              // Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
                  child: const Text('開始使用'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t, style: GoogleFonts.notoSansTc(fontSize: 10, letterSpacing: 0.2, color: AppColors.gold, fontWeight: FontWeight.w600));
  InputDecoration _inputDeco() => InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.divider)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), filled: true, fillColor: AppColors.surface);

  Widget _toggleRow(String l, String r, bool isRight, Function(bool) onChanged) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
    child: Row(children: [
      Expanded(child: GestureDetector(onTap: () => onChanged(false), child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: !isRight ? AppColors.primary : null, borderRadius: BorderRadius.circular(6)), child: Text(l, textAlign: TextAlign.center, style: GoogleFonts.notoSansTc(fontSize: 12, color: !isRight ? AppColors.textOnPrimary : AppColors.textPrimary))))),
      Expanded(child: GestureDetector(onTap: () => onChanged(true), child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: isRight ? AppColors.primary : null, borderRadius: BorderRadius.circular(6)), child: Text(r, textAlign: TextAlign.center, style: GoogleFonts.notoSansTc(fontSize: 12, color: isRight ? AppColors.textOnPrimary : AppColors.textPrimary))))),
    ]),
  );

  Widget _switchRow(String t, bool v, Function(bool) onChanged) => Row(children: [
    Expanded(child: Text(t, style: GoogleFonts.notoSerifTc(fontSize: 13, color: AppColors.textPrimary))),
    Switch(value: v, onChanged: onChanged, activeColor: AppColors.primary),
  ]);
}
