/// Payment service — wraps RevenueCat for IAP
/// RevenueCat SDK is already in pubspec.yaml (purchases_flutter)
/// Uncomment and configure when RevenueCat account is set up.

class PaymentService {
  // static const _apiKey = 'your_revenuecat_api_key';

  static Future<void> init() async {
    // await Purchases.setup(_apiKey);
    // await Purchases.setAttributes({
    //   'platform': 'typingself',
    // });
  }

  static Future<bool> purchaseProduct(String productId) async {
    // try {
    //   final purchaserInfo = await Purchases.purchaseProduct(productId);
    //   return purchaserInfo.entitlements.all['premium']?.isActive ?? false;
    // } catch (e) {
    //   return false;
    // }
    return false;
  }

  static Future<bool> restorePurchases() async {
    // try {
    //   final purchaserInfo = await Purchases.restorePurchases();
    //   return purchaserInfo.entitlements.all['premium']?.isActive ?? false;
    // } catch (e) {
    //   return false;
    // }
    return false;
  }

  static Map<String, String> get products => {
    'entry_assessment': 'HK\$22 — 完整人格測試',
    'premium_report': 'HK\$68 — 詳細分析報告',
    'quarterly_tracking': 'HK\$38/季 — 季度追蹤',
  };
}
