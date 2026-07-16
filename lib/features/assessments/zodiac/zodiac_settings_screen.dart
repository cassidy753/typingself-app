// ═══════════════════════════════════════════════════════════════════════
// ZodiacSettingsScreen — 出生時間+地點 Settings UI
// Lets user input birth hour/minute/location to compute Rising + Moon
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import 'zodiac_calculator.dart';
import 'zodiac_result_screen.dart';

class ZodiacSettingsScreen extends StatefulWidget {
  const ZodiacSettingsScreen({super.key});

  @override
  State<ZodiacSettingsScreen> createState() => _ZodiacSettingsScreenState();
}

class _ZodiacSettingsScreenState extends State<ZodiacSettingsScreen> {
  int _birthYear = 1995;
  int _birthMonth = 6;
  int _birthDay = 15;
  int _birthHour = 12;
  int _birthMinute = 0;
  String _location = '香港';
  bool _loading = true;

  final List<String> _locations = [
    '香港', '台北', '東京', '首爾', '上海', '新加坡', '倫敦', '紐約', '其他',
  ];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _birthYear = p.getInt('zodiac_birth_year') ?? 1995;
      _birthMonth = p.getInt('zodiac_birth_month') ?? 6;
      _birthDay = p.getInt('zodiac_birth_day') ?? 15;
      _birthHour = p.getInt('zodiac_birth_hour') ?? 12;
      _birthMinute = p.getInt('zodiac_birth_minute') ?? 0;
      _location = p.getString('zodiac_birth_location') ?? '香港';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('zodiac_birth_year', _birthYear);
    await p.setInt('zodiac_birth_month', _birthMonth);
    await p.setInt('zodiac_birth_day', _birthDay);
    await p.setInt('zodiac_birth_hour', _birthHour);
    await p.setInt('zodiac_birth_minute', _birthMinute);
    await p.setString('zodiac_birth_location', _location);
    await p.setBool('zodiac_advanced_done', true);
  }

  void _showResult() {
    _save();
    final sun = ZodiacCalculator.getSunSign(_birthMonth, _birthDay);
    final rising = ZodiacCalculator.getRisingSign(
      _birthHour,
      _birthMinute,
      month: _birthMonth,
      day: _birthDay,
      location: _location,
    );
    final moon = ZodiacCalculator.getMoonSign(
      _birthYear,
      _birthMonth,
      _birthDay,
      _birthHour,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZodiacResultScreen(
          sunSign: sun,
          risingSign: rising,
          moonSign: moon,
          birthDate: '${_birthYear}年${_birthMonth}月${_birthDay}日',
          birthTime: '${_birthHour.toString().padLeft(2, '0')}:${_birthMinute.toString().padLeft(2, '0')}',
          location: _location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('星座進階設定',
            style: GoogleFonts.notoSansTc(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.purple.withValues(alpha: 0.2),
                    AppColors.purple.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⬆️ 🌙', style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('輸入出生時間',
                      style: GoogleFonts.notoSerifTc(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '解鎖上升星座同月亮星座，\n了解更深層次嘅你',
                    style: GoogleFonts.notoSansTc(
                        fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Birth date ───
            _sectionLabel('出生日期'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberPicker('年', _birthYear, 1940, 2010, (v) {
                  setState(() => _birthYear = v);
                })),
                const SizedBox(width: 8),
                Expanded(child: _numberPicker('月', _birthMonth, 1, 12, (v) {
                  setState(() => _birthMonth = v);
                })),
                const SizedBox(width: 8),
                Expanded(child: _numberPicker('日', _birthDay, 1, 31, (v) {
                  setState(() => _birthDay = v);
                })),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Birth time ───
            _sectionLabel('出生時間（可揀大約）'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberPicker('時', _birthHour, 0, 23, (v) {
                  setState(() => _birthHour = v);
                })),
                const SizedBox(width: 8),
                Expanded(child: _numberPicker('分', _birthMinute, 0, 59, (v) {
                  setState(() => _birthMinute = v);
                })),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Location ───
            _sectionLabel('出生地點'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _location,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.notoSansTc(
                  fontSize: 15, color: AppColors.textPrimary),
              items: _locations
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _location = v);
              },
            ),
            const SizedBox(height: 32),

            // ─── Submit ───
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _showResult,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  textStyle: GoogleFonts.notoSansTc(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔮 查看我嘅星座增強版'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '⚠️ 計算基於簡化算法，同專業占星師可能有出入',
                style: GoogleFonts.notoSansTc(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.notoSansTc(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }

  Widget _numberPicker(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(value > min ? value - 1 : max),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.remove_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  value.toString(),
                  style: GoogleFonts.notoSansTc(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(value < max ? value + 1 : min),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.add_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.notoSansTc(
                fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
