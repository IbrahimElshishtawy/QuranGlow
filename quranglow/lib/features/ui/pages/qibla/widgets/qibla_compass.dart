// lib/features/ui/pages/qibla/widgets/qibla_compass.dart
// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/qibla_arrow.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  static const _kaabaLat = 21.4225;
  static const _kaabaLng = 39.8262;

  Position? _pos;
  StreamSubscription<Position>? _posSub;
  double? _heading; // degrees 0..360
  double? _bearingToQibla; // degrees 0..360
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
    FlutterCompass.events?.listen((e) {
      if (e.heading == null) return;
      setState(() => _heading = _normalize(e.heading!));
      _updateDelta();
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _error = 'فعّل خدمة الموقع ثم أعد المحاولة');
        return;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.deniedForever ||
          p == LocationPermission.denied) {
        setState(() => _error = 'صلاحية الموقع مرفوضة');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() => _pos = pos);
      _bearingToQibla = _bearing(
        pos.latitude,
        pos.longitude,
        _kaabaLat,
        _kaabaLng,
      );

      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
            ),
          ).listen((p) {
            setState(() => _pos = p);
            _bearingToQibla = _bearing(
              p.latitude,
              p.longitude,
              _kaabaLat,
              _kaabaLng,
            );
            _updateDelta();
          });
    } catch (e) {
      setState(() => _error = 'خطأ: $e');
    }
  }

  double? _delta; // الفرق بين البوصلة والقبلة

  void _updateDelta() {
    if (_heading == null || _bearingToQibla == null) return;
    final d = _bearingToQibla! - _heading!;
    _delta = _normalize(d);
    setState(() {});
  }

  // حساب زاوية القبلة بالنسبة للشمال الحقيقي
  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final q_1 = _deg2rad(lat1);
    final q_2 = _deg2rad(lat2);
    final s = _deg2rad(lon2 - lon1);
    final y = math.sin(s) * math.cos(q_2);
    final x =
        math.cos(q_1) * math.sin(q_2) -
        math.sin(q_1) * math.cos(q_2) * math.cos(s);
    final z = math.atan2(y, x);
    return _normalize(_rad2deg(z));
  }

  double _deg2rad(double d) => d * math.pi / 180.0;
  double _rad2deg(double r) => r * 180.0 / math.pi;

  double _normalize(double deg) {
    var d = deg % 360;
    if (d < 0) d += 360;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_error != null) {
      return _ErrorCard(message: _error!, onRetry: _init);
    }

    if (_pos == null) {
      return _LoadingCard();
    }

    final heading = _heading;
    final bearing = _bearingToQibla;
    final delta = _delta;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // قرص البوصلة
                  _CompassDial(rotationDeg: heading ?? 0),
                  // سهم القبلة: ندوره بفرق الزاوية
                  QiblaArrow(rotationDeg: delta ?? 0, color: cs.primary),
                  // مركز
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _InfoRow(heading: heading, bearing: bearing, delta: delta, cs: cs),
        const SizedBox(height: 12),
        Text(
          'وجّه الهاتف أفقيًا بعيدًا عن المعادن والمغناطيس.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _CompassDial extends StatelessWidget {
  final double rotationDeg; // دوران البوصلة حسب heading
  const _CompassDial({required this.rotationDeg});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Transform.rotate(
      angle:
          -rotationDeg *
          math.pi /
          180, // سالب لأننا ندوّر القرص عكس اتجاه الهاتف
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // علامة الشمال
            Positioned(
              top: 8,
              child: Icon(Icons.arrow_drop_up, size: 36, color: cs.error),
            ),
            // دوائر إرشادية
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(18),
              child: CustomPaint(painter: _RingsPainter(cs.outlineVariant)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final Color color;
  _RingsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final c = size.width / 2;
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(Offset(c, c), c * i / 3, p);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) => false;
}

class _InfoRow extends StatelessWidget {
  final double? heading;
  final double? bearing;
  final double? delta;
  final ColorScheme cs;

  const _InfoRow({
    required this.heading,
    required this.bearing,
    required this.delta,
    required this.cs,
  });

  String _fmt(double? v) => v == null ? '—' : '${v.toStringAsFixed(0)}°';

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Metric(
              icon: Icons.explore,
              label: 'البوصلة',
              value: _fmt(heading),
              cs: cs,
              style: style,
            ),
            _Metric(
              icon: Icons.place,
              label: 'زاوية القبلة',
              value: _fmt(bearing),
              cs: cs,
              style: style,
            ),
            _Metric(
              icon: Icons.navigation,
              label: 'اتّجه',
              value: _fmt(delta),
              cs: cs,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final TextStyle? style;

  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: style?.copyWith(color: cs.onSurfaceVariant)),
            Text(value, style: style?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(width: 12),
            const Text('جاري تحديد الموقع...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: cs.error),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
