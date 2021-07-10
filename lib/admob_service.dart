import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3991352577184641/4046757610'
      : 'ca-app-pub-3991352577184641/3076456724';

  static String get InterstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3991352577184641/8091419183'
      : 'ca-app-pub-3991352577184641/2950773140';

  static InterstitialAd _interstitialAd;

  static initalize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  static BannerAd createBannerAd() {
    BannerAd ad = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.largeBanner,
        request: AdRequest(),
        listener: AdListener());
    return ad;
  }

  static InterstitialAd _CreateInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAdUnitId,
      request: AdRequest(),
      listener: AdListener(
          onAdLoaded: (Ad ad) => _interstitialAd.show(),
          onAdClosed: (Ad ad) => _interstitialAd.dispose()),
    );
  }

  static void showInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    if (_interstitialAd == null) _interstitialAd = _CreateInterstitialAd();

    _interstitialAd.load();
  }
}
