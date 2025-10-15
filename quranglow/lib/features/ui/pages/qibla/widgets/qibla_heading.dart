import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quranglow/core/data/qibla_calculator.dart';
import 'package:quranglow/core/service/setting/location_service.dart';

class QiblaHeading extends StatefulWidget {
  const QiblaHeading({super.key});
  @override
  State<QiblaHeading> createState() => _QiblaHeadingState();
}

class _QiblaHeadingState extends State<QiblaHeading> {
  final _loc = LocationService();
  StreamSubscription<CompassEvent>? _compassSub;

  double? _heading;
  double? _smoothed;
  double? _qibla;
  String _status = '—';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final pos = await _loc.getCurrentOnce();
    if (pos != null) {
      _qibla = QiblaCalculator.bearingToKaaba(
        userLat: pos.latitude,
        userLng: pos.longitude,
      );
    }

    _compassSub = FlutterCompass.events?.listen((e) {
      if (e.accuracy?.index == 0) {
        // SensorAccuracy.low/unreliable حسب الإصدار
        _status = 'Calibration needed';
      } else {
        _status = 'OK';
      }

      final h = e.heading;
      if (h == null) return;

      _smoothed = (_smoothed == null) ? h : (_smoothed! * 0.85 + h * 0.15);
      _heading = h;

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _loc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _smoothed ?? _heading;
    final q = _qibla;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Sensor: $_status'),
        const SizedBox(height: 8),
        Text(
          'Heading: ${h?.toStringAsFixed(0) ?? "--"}°',
          style: const TextStyle(fontSize: 20),
        ),
        if (q != null)
          Text(
            'Qibla: ${q.toStringAsFixed(0)}°',
            style: const TextStyle(fontSize: 20),
          ),
        const SizedBox(height: 12),
        if (_status != 'OK')
          const Text(
            'حرّك الهاتف شكل 8 وأبعده عن المعادن/المغناطيس.',
            style: TextStyle(color: Colors.orange),
          ),
      ],
    );
  }
}
