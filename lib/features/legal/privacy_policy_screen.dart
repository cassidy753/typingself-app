// ═══════════════════════════════════════════════════════════════════════
// PrivacyPolicyScreen — 私隱政策 (PDPO-compliant HK Cantonese)
// Daebi palette · Noto Serif/Sans TC
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/analytics_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final Color accent;
  final Color accentBg;

  const PrivacyPolicyScreen({
    super.key,
    this.accent = AppColors.primary,
    this.accentBg = const Color(0x205C4033),
  });

  @override
  Widget build(BuildContext context) {
    // Log analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.log(AnalyticsService.legalViewed, properties: {'page': 'privacy_policy'});
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.2))),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Semantics(
                      label: '返回',
                      button: true,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44, height: 44,
                          padding: const EdgeInsets.all(5),
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
                    ),
                    const SizedBox(width: 10),
                    Text('私隱政策', style: GoogleFonts.notoSerifTc(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最後更新：2025 年 1 月', style: GoogleFonts.notoSansTc(
              fontSize: 13, color: AppColors.textMuted,
            )),
            const SizedBox(height: 20),

            _section('1. 我哋收集嘅資料'),
            _body('型得你（下稱「我哋」）重視你嘅私隱。我哋收集以下資料以提供個人化服務：'),
            _bullet('你提供嘅人格測試結果（MBTI、Enneagram 等）'),
            _bullet('你嘅每日心情記錄'),
            _bullet('你嘅裝置 token（用於每日推送通知）'),
            _bullet('App 使用數據（例如使用頻率、功能互動）'),
            _bullet('你揀嘅星座設定'),
            const SizedBox(height: 16),

            _section('2. 資料用途'),
            _body('我哋使用你嘅資料用於：'),
            _bullet('提供個人化語句同分析'),
            _bullet('改善 App 功能同用戶體驗'),
            _bullet('發送每日推送通知（如果你開啟咗）'),
            _bullet('內部統計同趨勢分析'),
            const SizedBox(height: 16),

            _section('3. 資料儲存同安全'),
            _body('你嘅資料主要儲存喺你嘅裝置本地 (SharedPreferences) 同我哋嘅雲端伺服器 (Supabase)。'),
            _body('我哋採取合理嘅技術措施保護你嘅個人資料，包括加密傳輸同訪問控制。'),
            const SizedBox(height: 16),

            _section('4. 資料分享'),
            _body('我哋唔會出售你嘅個人資料俾第三方。'),
            _body('我哋可能喺以下情況分享資料：'),
            _bullet('得到你明確嘅同意'),
            _bullet('法律要求或配合執法機構'),
            _bullet('使用第三方服務供應商（例如雲端寄存），佢哋必須遵守嚴格嘅保密條款'),
            const SizedBox(height: 16),

            _section('5. 你嘅權利'),
            _body('根據香港《個人資料（私隱）條例》(PDPO)，你有權：'),
            _bullet('查閱我哋持有嘅你嘅個人資料'),
            _bullet('要求更正唔準確嘅資料'),
            _bullet('要求刪除你嘅資料同帳戶'),
            _bullet('撤回你嘅同意（喺設定頁面可以開關「資料使用同意」）'),
            const SizedBox(height: 16),

            _section('6. 資料保留'),
            _body('我哋會保留你嘅資料直到你要求刪除帳戶，或者 App 停止運作後合理時間內。'),
            const SizedBox(height: 16),

            _section('7. 聯絡我哋'),
            _body('如果你對呢份私隱政策有任何疑問，或者想行使你嘅權利，請聯絡我哋：'),
            _body('電郵：privacy@xingdeni.app', bold: false),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.notoSerifTc(
        fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
      )),
    );
  }

  Widget _body(String text, {bool bold = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.notoSansTc(
        fontSize: 14, fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
        color: AppColors.textSecondary, height: 1.6,
      )),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.notoSansTc(
            fontSize: 14, color: AppColors.textSecondary,
          )),
          Expanded(
            child: Text(text, style: GoogleFonts.notoSansTc(
              fontSize: 14, color: AppColors.textSecondary, height: 1.5,
            )),
          ),
        ],
      ),
    );
  }
}
