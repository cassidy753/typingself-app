import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'naming_engine.dart';
import 'share_card.dart';

class NamingScreen extends ConsumerStatefulWidget {
  const NamingScreen({super.key});

  @override
  ConsumerState<NamingScreen> createState() => _NamingScreenState();
}

class _NamingScreenState extends ConsumerState<NamingScreen> {
  String? _mbti, _enneagram;
  PersonalityName? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🧠'),
            ),
            const SizedBox(width: 10),
            Text('型得你', style: GoogleFonts.notoSerifHk(
              fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
            )),
          ],
        ),
      ),
      body: SafeArea(
        child: _result != null ? _buildResult() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Hero text
          Text('你係邊型？', style: GoogleFonts.notoSerifHk(
            fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 8),
          Text(
            '揀你嘅 MBTI 同 Enneagram，睇下你個地道廣東話名',
            style: GoogleFonts.notoSansHk(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 40),

          // MBTI
          Text('MBTI 類型', style: GoogleFonts.notoSansHk(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
          )),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _mbti,
            items: NamingEngine.mbtiTypes,
            hint: '揀你嘅 MBTI…',
            onChanged: (v) => setState(() => _mbti = v),
          ),

          const SizedBox(height: 24),

          // Enneagram
          Text('九型人格', style: GoogleFonts.notoSansHk(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
          )),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _enneagram,
            items: NamingEngine.enneagramTypes,
            hint: '揀你嘅九型人格…',
            onChanged: (v) => setState(() => _enneagram = v),
          ),

          const Spacer(),

          // Go button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: (_mbti != null && _enneagram != null) ? _generate : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text('睇我個名', style: GoogleFonts.notoSansHk(
                    fontSize: 16, fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.notoSansHk(
            fontSize: 15, color: AppColors.textMuted,
          )),
          items: items.map((t) => DropdownMenuItem(
            value: t,
            child: Text(t, style: GoogleFonts.notoSansHk(
              fontSize: 15, fontWeight: FontWeight.w500,
            )),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildResult() {
    final name = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF5B21B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(name.emoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text(
                  name.nameCanto,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifHk(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${name.mbti} · ${name.enneagram}',
                    style: GoogleFonts.notoSansHk(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '「${name.tagline}」',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerifHk(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Encourage
          if (name.encourage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('💜', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name.encourage,
                      style: GoogleFonts.notoSansHk(
                        fontSize: 14, color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Share
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => ShareCard.share(context, name),
              icon: const Icon(Icons.share, size: 18),
              label: Text('分享俾朋友', style: GoogleFonts.notoSansHk(
                fontSize: 15, fontWeight: FontWeight.w600,
              )),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Try again
          TextButton(
            onPressed: () => setState(() { _result = null; _mbti = null; _enneagram = null; }),
            child: Text('再試其他組合', style: GoogleFonts.notoSansHk(
              fontSize: 13, color: AppColors.textMuted,
            )),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _generate() {
    final name = NamingEngine.getName(_mbti!, _enneagram!);
    if (name != null) {
      setState(() => _result = name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('呢個 combo 未命名，遲啲會有！',
            style: GoogleFonts.notoSansHk(fontSize: 13)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
