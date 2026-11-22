/// How aruṇa (dawn) is reckoned. The enum name is the saved key.
enum DawnMethod {
  /// Sunrise − 40 minutes.
  paAuk,

  /// Sunrise − 30 minutes.
  naUyana,

  /// The sun 6° below the horizon.
  civilTwilight,

  /// Sunrise itself.
  sunrise;

  /// The method used until the user picks one.
  static const fallback = DawnMethod.naUyana;
}
