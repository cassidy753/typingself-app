import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class MyTypeScreen extends StatelessWidget {
  const MyTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(child: Text('🧠', style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 12),
                Text('高級KAM L',
                  style: GoogleFonts.notoSerifTc(
                    fontSize: 32, fontWeight: FontWeight.w900,
                    color: AppColors.secondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('ENFJ · 5w4', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
                ),
                const SizedBox(height: 12),
                Text('「你睇到人哋睇唔到嘅 pattern」',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Expanded(
                child: _ActionBtn('📤  Share', AppColors.secondary, Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn('✏️ 轉 tagline', AppColors.primary.withValues(alpha: 0.1), AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Friends
          Text('朋友嘅型', style: GoogleFonts.notoSerifTc(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 10),
          _FriendRow('🎯', '行動先鋒', 'ESTP · 7w8'),
          const SizedBox(height: 8),
          _AddFriend(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _ActionBtn(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Text(text, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: fg))),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final String emoji, name, type;
  const _FriendRow(this.emoji, this.name, this.type);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                Text(type, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Text('+', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _AddFriend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text('+ 邀請朋友', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ),
    );
  }
}
