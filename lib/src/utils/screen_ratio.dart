/// Common portrait aspect ratios (width / height).
///
/// Use [value] for the portrait ratio and [landscape] for the rotated one.
/// Device lists are examples of screens at or very near each ratio, not
/// an exhaustive list.
enum ScreenRatio {
  /// 9:16 (0.5625). Classic 16:9 phones.
  ///
  /// iPhone 6/7/8/SE, Galaxy S5 to S7, Pixel 1/2, most 720p/1080p
  /// budget Android phones.
  phone(9 / 16),

  /// 9:19.5 (0.4615). Modern tall phones.
  ///
  /// iPhone X, 11 Pro, 12, 13, 14, 15, 16, Galaxy S21 to S24.
  /// Pixel 6/7/8 are 9:20 (0.45), so they blend in from this ratio.
  phoneTall(9 / 19.5),

  /// 9:21 (0.4286). Very tall phones.
  ///
  /// Sony Xperia 1 and Xperia 5 series. Foldable cover screens
  /// (Galaxy Z Fold 3 to 5, about 0.37 to 0.39) are even narrower, so they
  /// use this ratio as their clamped end unless you add a custom key.
  phoneUltraTall(9 / 21),

  /// 10:16 (0.625). Android tablets.
  ///
  /// Galaxy Tab S4/S5e and the 11" S7/S8/S9, Nexus 7 (2013), many
  /// Lenovo and Xiaomi tablets.
  tablet(10 / 16),

  /// 3:4 (0.75). Classic iPad.
  ///
  /// iPad 9.7" and 10.2", iPad Air 1/2/3, iPad Pro 9.7" and 12.9",
  /// and a single Surface Duo 1 screen (1350x1800).
  iPad(3 / 4),

  /// 1668:2388 (about 0.698). Modern iPad.
  ///
  /// iPad Pro 11", iPad Air 10.9" (4th gen and later), iPad 10th gen.
  /// A single Surface Duo 2 screen (1344x1892, about 0.71) is also very close.
  iPadPro(1668 / 2388),

  /// 1812:2176 (about 0.833). Unfolded foldables.
  ///
  /// Galaxy Z Fold 5 inner screen, Pixel Fold (1840x2208).
  /// Galaxy Z Fold 3/4 are slightly narrower (1768x2208, 0.80).
  foldable(1812 / 2176),

  /// 1892:2688 (about 0.704). Dual-screen devices spanned across both panels.
  ///
  /// Microsoft Surface Duo 2 (1892x2688). Surface Duo 1 spanned
  /// (1800x2700, 0.667) falls between [tablet] and [iPadPro].
  dualScreen(1892 / 2688),

  /// 1:1. Square displays.
  ///
  /// BlackBerry Passport, some kiosks and wearable-style displays.
  square(1);

  const ScreenRatio(this.value);

  /// Portrait aspect ratio (width / height).
  final double value;

  /// Landscape aspect ratio (the portrait ratio rotated, height / width).
  double get landscape => 1 / value;
}