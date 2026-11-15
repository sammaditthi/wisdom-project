/// A place the Buddhist times are worked out for. The enum name is the saved
/// key, so renaming a value loses that user's choice.
enum City {
  colombo(6.9271, 79.8612),
  kandy(7.2906, 80.6337),
  galle(6.0535, 80.2210),
  kurunegala(7.4863, 80.3623),
  anuradhapura(8.3114, 80.4037),
  jaffna(9.6615, 80.0255),
  trincomalee(8.5874, 81.2152),
  batticaloa(7.7310, 81.6747);

  const City(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// The city used until the user picks one.
  static const fallback = City.colombo;

  /// Sri Lanka's clock, the same all year. Every city in the list is on it.
  static const utcOffset = Duration(hours: 5, minutes: 30);

  /// The calendar day it is in the city at [instant], as a UTC-midnight date.
  static DateTime dayAt(DateTime instant) {
    final local = instant.toUtc().add(utcOffset);
    return DateTime.utc(local.year, local.month, local.day);
  }
}
