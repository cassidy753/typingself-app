// ═══════════════════════════════════════════════════════════════════════
// TermsScreen — 服務條款 (HK Cantonese · PDPO compliant)
// Daebi palette · Noto Serif/Sans TC
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/analytics_service.dart';

class TermsScreen extends StatelessWidget {
  final Color accent;
  final Color accentBg;

  const TermsScreen({
    super.key,
    this.accent = AppColors.primary,
    this.accentBg = const Color(0x205C4033),
  });

  @override
  Widget build(BuildContext context) {
    // Log analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.log(AnalyticsService.legalViewed, properties: {'page': 'terms'});
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
                    Text('服務條款', style: GoogleFonts.notoSerifTc(
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

            _section('1. 接受條款'),
            _body('下載或使用「型得你」App，即表示你同意受本服務條款約束。如果你唔同意任何部分，請唔好使用本 App。'),
            const SizedBox(height: 16),

            _section('2. 服務描述'),
            _body('型得你係一個人格成長 App，提供 MBTI、Enneagram 等人格測試，以及每日語句、心情記錄、Shadow Report、成長練習等功能。'),
            _body('我哋會持續更新同改善服務，但唔保證服務永遠唔會中斷或冇錯誤。'),
            const SizedBox(height: 16),

            _section('3. 用戶責任'),
            _bullet('你必須年滿 13 歲或以上先可以使用本 App'),
            _bullet('你提供嘅資料必須準確同真實'),
            _bullet('你唔可以使用本 App 進行任何違法活動'),
            _bullet('你唔可以嘗試破解、逆向工程或干擾 App 嘅正常運作'),
            const SizedBox(height: 16),

            _section('4. 知識產權'),
            _body('型得你 App 嘅所有內容，包括文字、圖像、標誌、程式碼，都屬於我哋嘅知識產權。未經許可，你唔可以複製、修改或分發任何內容。'),
            const SizedBox(height: 16),

            _section('5. 付款同訂閱'),
            _body('部分功能（如深度報告）可能需要付費。所有付款經由 Apple App Store 或 Google Play 處理，我哋唔會儲存你嘅支付資料。'),
            _body('訂閱會自動續期，除非你喺當期結束前至少 24 小時取消。你可以隨時喺帳戶設定管理訂閱。'),
            const SizedBox(height: 16),

            _section('6. 免責聲明'),
            _body('本 App 提供嘅人格測試同分析僅供參考同自我認識用途，唔構成心理學診斷、治療或專業意見。'),
            _body('如果你需要心理健康支援，請聯絡註冊心理學家或相關專業人士。'),
            const SizedBox(height: 16),

            _section('7. 服務終止'),
            _body('我哋保留暫停或終止任何違反本條款嘅用戶帳戶嘅權利。你可以隨時刪除帳戶同所有相關資料。'),
            const SizedBox(height: 16),

            _section('8. 條款變更'),
            _body('我哋可能會更新本服務條款。重大變更會通過 App 內通知或電郵通知你。繼續使用本 App 即表示你接受更新後嘅條款。'),
            const SizedBox(height: 16),

            _section('9. 適用法律'),
            _body('本服務條款受香港特別行政區法律管轄。'),
            const SizedBox(height: 16),

            _section('10. 聯絡我哋'),
            _body('如果你有任何問題，請聯絡我哋：'),
            _body('電郵：support@xingdeni.app', bold: false),
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
