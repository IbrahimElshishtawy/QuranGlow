import 'dart:math';

class QiblaCalculator {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  static double bearingToKaaba({
    required double userLat,
    required double userLng,
  }) {
    final lat1 = _deg2rad(userLat);
    final lat2 = _deg2rad(_kaabaLat);
    final dLng = _deg2rad(_kaabaLng - userLng);

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    var brng = _rad2deg(atan2(y, x)); // -180..180
    brng = (brng + 360.0) % 360.0; // 0..360
    return brng;
  }

  static double _deg2rad(double d) => d * pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / pi;
}
