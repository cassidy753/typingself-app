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
    'monthly': 'HK\$8/月 — 完整人格測試',
    'report': 'HK\$18 — 詳細分析報告',
    'annual': 'HK\$80/年 — Premium',
  };
}
