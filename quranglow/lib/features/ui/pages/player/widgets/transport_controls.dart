// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/model/Play_list_State.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/position_bar.dart';

class TransportControls extends ConsumerWidget {
  const TransportControls({super.key, required this.state});
  final PlaylistState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PositionBar(
          durationStream: state.durationStream,
          positionStream: state.positionStream,
          onSeek: ref.read(playerControllerProvider.notifier).seekTo,
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
            _SpeedMenu(
              onSelect: (v) {
                // يمكن لاحقًا ضبط setSpeed على المشغّل إن رغبت
                ref
                    .read(playerControllerProvider.notifier)
                    .seekTo(const Duration());
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

class _SpeedMenu extends StatefulWidget {
  const _SpeedMenu({required this.onSelect});
  final void Function(double) onSelect;
  @override
  State<_SpeedMenu> createState() => _SpeedMenuState();
}

class _SpeedMenuState extends State<_SpeedMenu> {
  double _speed = 1.0;
  final _options = const [0.5, 0.75, 1.0, 1.25, 1.5];
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'السرعة',
      onSelected: (v) {
        setState(() => _speed = v);
        widget.onSelect(v);
      },
      itemBuilder: (context) => _options
          .map((v) => PopupMenuItem(value: v, child: Text('${v}x')))
          .toList(),
      child: const Chip(
        avatar: Icon(Icons.speed_rounded, size: 18),
        label: Text('السرعة'),
      ),
    );
  }
}
