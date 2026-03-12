import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/book/Play_list_State.dart';
import 'package:quranglow/features/player/presentation/widgets/position_bar.dart';
import 'package:quranglow/features/player/presentation/widgets/speed_menu.dart';

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
          timelineStream: state.timelineStream,
          onSeek: ref.read(playerControllerProvider.notifier).seekTo,
        ),
        const SizedBox(height: 14),
        StreamBuilder<int?>(
          stream: state.indexStream,
          initialData: 0,
          builder: (_, indexSnap) {
            final currentAyah = (indexSnap.data ?? 0) + 1;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.65),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.multitrack_audio_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(
                    'الآية الحالية: $currentAyah من ${state.total}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleAction(
              tooltip: 'السابق',
              icon: Icons.skip_previous_rounded,
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).previous(),
            ),
            const SizedBox(width: 12),
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
                    size: 30,
                  ),
                  label: Text(playing ? 'إيقاف مؤقت' : 'تشغيل'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(154, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _CircleAction(
              tooltip: 'التالي',
              icon: Icons.skip_next_rounded,
              onPressed: () => ref.read(playerControllerProvider.notifier).next(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
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
              label: const Text('تكرار السورة'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).toggleMute(),
              icon: const Icon(Icons.volume_off_rounded, size: 18),
              label: const Text('كتم الصوت'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
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

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(52, 52),
        backgroundColor: cs.surfaceContainerLow,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      icon: Icon(icon, size: 28, color: cs.primary),
    );
  }
}
