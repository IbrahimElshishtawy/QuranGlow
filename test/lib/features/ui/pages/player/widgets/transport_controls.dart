// transport_controls.dart
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:test/core/model/book/Play_list_State.dart';
import 'package:test/features/ui/pages/player/controller/player_controller.dart';
import 'package:test/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:test/features/ui/pages/player/widgets/speed_menu.dart';

final playbackSpeedProvider = StateProvider<double>((_) => 1.0);

class TransportControls extends ConsumerWidget {
  const TransportControls({super.key, required this.state});
  final PlaylistState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final speed = ref.watch(playbackSpeedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PositionBar(
          durationStream: state.durationStream,
          positionStream: state.positionStream,
          onSeek: ref.read(playerControllerProvider.notifier).seekTo,
          bufferedStream: state.bufferedStream,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'السابق',
              icon: const Icon(Icons.skip_previous_rounded, size: 28),
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).previous(),
            ),
            const SizedBox(width: 8),
            StreamBuilder<bool>(
              stream: state.playingStream,
              initialData: false,
              builder: (_, snap) {
                final playing = snap.data ?? false;
                return FilledButton.tonalIcon(
                  onPressed: () => playing
                      ? ref.read(playerControllerProvider.notifier).pause()
                      : ref.read(playerControllerProvider.notifier).play(),
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 28,
                  ),
                  label: Text(playing ? 'إيقاف مؤقت' : 'تشغيل'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'التالي',
              icon: const Icon(Icons.skip_next_rounded, size: 28),
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).next(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            SpeedMenu(
              currentSpeed: speed,
              onSelect: (v) {
                ref.read(playbackSpeedProvider.notifier).state = v;
                ref.read(playerControllerProvider.notifier).setSpeed(v);
              },
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).toggleLoop(),
              icon: const Icon(Icons.repeat_rounded, size: 18),
              label: const Text('تكرار'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).toggleMute(),
              icon: const Icon(Icons.volume_off_rounded, size: 18),
              label: const Text('صامت'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
