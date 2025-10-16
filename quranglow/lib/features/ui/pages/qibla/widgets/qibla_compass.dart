// lib/features/ui/pages/qibla/widgets/qibla_compass.dart
// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import 'package:quranglow/features/ui/pages/qibla/widgets/compass_dial.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/info_row.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/loading_error.dart';
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
  StreamSubscription<CompassEvent>? _compassSub;

  double? _heading; // 0..360
  double? _bearingToQibla; // 0..360
  double? _delta; // فرق الزاوية
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
    _compassSub = FlutterCompass.events?.listen((e) {
      final h = e.heading;
      if (h == null) return;
      _heading = _normalize(h);
      _updateDelta();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _compassSub?.cancel();
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
      _pos = pos;
      _bearingToQibla = _bearing(
        pos.latitude,
        pos.longitude,
        _kaabaLat,
        _kaabaLng,
      );
      setState(() {});

      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
            ),
          ).listen((p) {
            _pos = p;
            _bearingToQibla = _bearing(
              p.latitude,
              p.longitude,
              _kaabaLat,
              _kaabaLng,
            );
            _updateDelta();
            if (mounted) setState(() {});
          });
    } catch (e) {
      setState(() => _error = 'خطأ: $e');
    }
  }

  void _updateDelta() {
    if (_heading == null || _bearingToQibla == null) return;
    final d = _bearingToQibla! - _heading!;
    _delta = _normalize(d);
  }

  // حساب زاوية القبلة بالنسبة للشمال الحقيقي
  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final q1 = _deg2rad(lat1);
    final q2 = _deg2rad(lat2);
    final s = _deg2rad(lon2 - lon1);
    final y = math.sin(s) * math.cos(q2);
    final x =
        math.cos(q1) * math.sin(q2) - math.sin(q1) * math.cos(q2) * math.cos(s);
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

    if (_error != null) return ErrorCard(message: _error!, onRetry: _init);
    if (_pos == null) return const LoadingCard();

    final heading = _heading ?? 0;
    final delta = _delta ?? 0;

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
                  CompassDial(
                    rotationDeg: heading,
                    ringsColor: cs.outlineVariant,
                  ),
                  QiblaArrow(rotationDeg: delta, color: cs.primary),
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
        InfoRow(heading: _heading, bearing: _bearingToQibla, delta: _delta),
        const SizedBox(height: 12),
        Text(
          'وجّه الهاتف أفقيًا بعيدًا عن المعادن والمغناطيس.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
