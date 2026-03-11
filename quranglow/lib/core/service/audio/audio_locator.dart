// lib/core/audio/audio_locator.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'my_audio_handler.dart';

late final MyAudioHandler audioHandler;

Future<void> initAudioHandler() async {
  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'playback_ch',
      androidNotificationChannelName: 'تشغيل الصوت',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationClickStartsActivity: true,
      notificationColor: Color(0xFF1B5E20),
    ),
  );
}
