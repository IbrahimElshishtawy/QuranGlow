// lib/features/ui/pages/qibla/widgets/QiblaCompassState.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import 'package:quranglow/features/ui/pages/qibla/widgets/compass_dial.dart'
    as dial;
import 'package:quranglow/features/ui/pages/qibla/widgets/info_row.dart'
    as info;
import 'package:quranglow/features/ui/pages/qibla/widgets/loading_error.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/qibla_arrow.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/qibla_compass.dart';

class QiblaCompassState extends State<QiblaCompass> {
  static const _kaabaLat = 21.4225, _kaabaLng = 39.8262;

  Position? _pos;
  StreamSubscription<Position>? _posSub;
  StreamSubscription<CompassEvent>? _compassSub;

  String _sensorStatus = '—';
  bool _usingCourse = false;
  double? _heading;
  double? _smoothedHeading;
  double? _bearingToQibla;
  double? _delta;
  String? _error;

  int _initSeq = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _cancelStreams();
    super.dispose();
  }

  void _cancelStreams() {
    _posSub?.cancel();
    _posSub = null;
    _compassSub?.cancel();
    _compassSub = null;
  }

  void _safeSet(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _init() async {
    final seq = ++_initSeq;
    _cancelStreams();
    _usingCourse = false;
    _sensorStatus = '—';
    _heading = _smoothedHeading = _delta = null;
    _error = null;

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (seq != _initSeq || !mounted) return;
      if (!enabled) {
        _safeSet(() => _error = 'فعّل خدمة الموقع ثم أعد المحاولة');
        return;
      }

      LocationPermission p = await Geolocator.checkPermission();
      if (seq != _initSeq || !mounted) return;
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (seq != _initSeq || !mounted) return;
      if (p == LocationPermission.deniedForever ||
          p == LocationPermission.denied) {
        _safeSet(() => _error = 'صلاحية الموقع مرفوضة');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (seq != _initSeq || !mounted) return;
      _pos = pos;
      _bearingToQibla = _bearing(
        pos.latitude,
        pos.longitude,
        _kaabaLat,
        _kaabaLng,
      );
      _safeSet(() {});

      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              distanceFilter: 2,
            ),
          ).listen((p) {
            if (!mounted || seq != _initSeq) return;
            _pos = p;
            _bearingToQibla = _bearing(
              p.latitude,
              p.longitude,
              _kaabaLat,
              _kaabaLng,
            );

            if (_usingCourse || _heading == null) {
              if (p.speed > 1.0 && p.heading >= 0) {
                final course = _normalize(p.heading);
                _usingCourse = true;
                _sensorStatus = 'GPS-course';
                _applyHeading(course);
              }
            }

            _updateDelta();
            _safeSet(() {});
          });

      _compassSub = FlutterCompass.events?.listen((e) {
        if (!mounted || seq != _initSeq) return;

        final acc = e.accuracy;
        if (acc == null) {
          _sensorStatus = 'Unknown';
        } else {
          final needsCalib = (acc <= 1) || (acc < 0) || (acc > 15);
          _sensorStatus = needsCalib ? 'Calibration needed' : 'OK';
        }

        if (e.heading != null) {
          _usingCourse = false;
          _applyHeading(_normalize(e.heading!));
          _updateDelta();
          _safeSet(() {});
        }
      });
    } catch (e) {
      if (seq != _initSeq || !mounted) return;
      _safeSet(() => _error = 'خطأ: $e');
    }
  }

  void _applyHeading(double h) {
    _heading = h;
    _smoothedHeading = (_smoothedHeading == null)
        ? h
        : (_smoothedHeading! * 0.85 + h * 0.15);
  }

  void _updateDelta() {
    final src = _smoothedHeading ?? _heading;
    if (src == null || _bearingToQibla == null) return;
    _delta = _normalize(_bearingToQibla! - src);
  }

  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final q1 = _deg2rad(lat1), q2 = _deg2rad(lat2), s = _deg2rad(lon2 - lon1);
    final y = math.sin(s) * math.cos(q2);
    final x =
        math.cos(q1) * math.sin(q2) - math.sin(q1) * math.cos(q2) * math.cos(s);
    return _normalize(_rad2deg(math.atan2(y, x)));
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

    final heading = (_smoothedHeading ?? _heading) ?? 0;
    final delta = _delta ?? 0;

    final hint = _usingCourse
        ? 'لا توجد بوصلة. تحرّك قليلًا ليُستنتج الاتجاه من GPS.'
        : (_sensorStatus == 'Calibration needed'
              ? 'حرّك الهاتف شكل 8 وأبعده عن المعادن/المغناطيس.'
              : 'وجّه الهاتف أفقيًا بعيدًا عن المعادن والمغناطيس.');

    final hintColor = _usingCourse
        ? Colors.orange
        : (_sensorStatus == 'Calibration needed'
              ? Colors.orange
              : cs.onSurfaceVariant);

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
                  dial.CompassDial(
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
        info.InfoRow(
          heading: _smoothedHeading ?? _heading,
          bearing: _bearingToQibla,
          delta: _delta,
        ),
        const SizedBox(height: 12),
        Text(hint, style: TextStyle(color: hintColor)),
      ],
    );
  }
}
