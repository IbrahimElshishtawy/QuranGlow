import 'package:flutter/material.dart';
import 'package:quranglow/features/qibla/presentation/widgets/QiblaCompassState.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({
    super.key,
    this.showEffects = true,
    this.showCalibrationCard = true,
    this.showHintCard = true,
    this.showInfoCards = true,
  });

  final bool showEffects;
  final bool showCalibrationCard;
  final bool showHintCard;
  final bool showInfoCards;

  @override
  State<QiblaCompass> createState() => QiblaCompassState();
}
