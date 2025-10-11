// lib/features/ui/pages/qibla/widgets/qibla_compass.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/qibla_arrow.dart';

import 'compass_dial.dart';
import 'info_row.dart';
import 'loading_error.dart';


class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});
  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  static const _kaabaLat = 21.4225, _kaabaLng = 39.8262;

  Position? _pos;
  StreamSubscription<Position>? _posSub;
  double? _heading, _bearingToQibla, _delta;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
    FlutterCompass.events?.listen((e) {
      if (e.heading == null) return;
      _heading = _normalize(e.heading!);
      _updateDelta();
      setState(() {});
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
      if (!enabled) { _error = 'فعّل خدمة الموقع ثم أعد المحاولة'; setState(() {}); return; }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) { p = await Geolocator.requestPermission(); }
      if (p == LocationPermission.deniedForever || p == LocationPermission.denied) {
        _error = 'صلاحية الموقع مرفوضة'; setState(() {}); return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      _pos = pos;
      _bearingToQibla = _bearing(pos.latitude, pos.longitude, _kaabaLat, _kaabaLng);
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).listen((p) {
        _pos = p;
        _bearingToQibla = _bearing(p.latitude, p.longitude, _kaabaLat, _kaabaLng);
        _updateDelta();
        setState(() {});
      });
      setState(() {});
    } catch (e) {
      _error = 'خطأ: $e'; setState(() {});
    }
  }

  void _updateDelta() {
    if (_heading == null || _bearingToQibla == null) return;
    _delta = _normalize(_bearingToQibla! - _heading!);
  }

  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final n = _deg2rad(lat1), p = _deg2rad(lat2), s = _deg2rad(lon2 - lon1);
    final y = math.sin(s) * math.cos(p);
    final x = math.cos(n) * math.sin(p) - math.sin(n) * math.cos(p) * math.cos(s);
    return _normalize(_rad2deg(math.atan2(y, x)));
  }
  double _deg2rad(double d) => d * math.pi / 180.0;
  double _rad2deg(double r) => r * 180.0 / math.pi;
  double _normalize(double deg) { var d = deg % 360; if (d < 0) d += 360; return d; }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_error != null) return ErrorCard(message: _error!, onRetry: _init);
    if (_pos == null) return const LoadingCard();

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
                  CompassDial(rotationDeg: _heading ?? 0, ringsColor: cs.outlineVariant),
                  QiblaArrow(rotationDeg: _delta ?? 0, color: cs.primary),
                  Container(width: 10, height: 10,
                      decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        InfoRow(heading: _heading, bearing: _bearingToQibla, delta: _delta),
        const SizedBox(height: 12),
        Text('وجّه الهاتف أفقيًا بعيدًا عن المعادن والمغناطيس.',
            style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
