import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // Google test ad unit IDs. Replace with your own before release.
  static String get bannerId => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'ca-app-pub-9953234712626365/2514803418',
    TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2934735716',
    _ => throw UnsupportedError('Ads are only supported on Android and iOS.'),
  };

  static String get interstitialId => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'ca-app-pub-9953234712626365/9738028177',
    TargetPlatform.iOS => 'ca-app-pub-3940256099942544/4411468910',
    _ => throw UnsupportedError('Ads are only supported on Android and iOS.'),
  };

  static String get rewardedId => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'ca-app-pub-9953234712626365/8756118997',
    TargetPlatform.iOS => 'ca-app-pub-3940256099942544/1712485313',
    _ => throw UnsupportedError('Ads are only supported on Android and iOS.'),
  };

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  int _solvedCount = 0;

  bool get isRewardedReady => _rewarded != null;

  Future<void> initialize() async {
    if (!isSupportedPlatform) return;
    await MobileAds.instance.initialize();
    preload();
  }

  void preload() {
    if (!isSupportedPlatform) return;
    _loadInterstitial();
    _loadRewarded();
  }

  // ---------- Interstitial ----------
  void _loadInterstitial() {
    if (_isInterstitialLoading || _interstitial != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialLoading = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (e) {
          _isInterstitialLoading = false;
          debugPrint('Interstitial failed: $e');
          _interstitial = null;
        },
      ),
    );
  }

  /// Call after a puzzle is solved. Shows an ad every 2nd time.
  void maybeShowInterstitial() {
    if (!isSupportedPlatform) return;
    _solvedCount++;
    if (_solvedCount % 2 != 0) return;

    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, e) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
    );
    ad.show();
  }

  // ---------- Rewarded ----------
  void _loadRewarded() {
    if (_isRewardedLoading || _rewarded != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isRewardedLoading = false;
          _rewarded = ad;
        },
        onAdFailedToLoad: (e) {
          _isRewardedLoading = false;
          debugPrint('Rewarded failed: $e');
          _rewarded = null;
        },
      ),
    );
  }

  /// Shows a rewarded ad. [onReward] runs only if the user earns the reward.
  /// If no ad is ready, [onNotReady] runs (so you can give the hint anyway).
  void showRewarded({
    required VoidCallback onReward,
    VoidCallback? onNotReady,
  }) {
    if (!isSupportedPlatform) {
      onNotReady?.call();
      return;
    }

    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      onNotReady?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, e) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        onNotReady?.call();
      },
    );

    ad.show(onUserEarnedReward: (_, __) => onReward());
  }
}