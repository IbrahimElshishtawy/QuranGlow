// lib/features/ui/pages/player/widgets/transport_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranglow/core/model/Play_list_State.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/position_bar.dart';

class TransportControls extends ConsumerWidget {
  const TransportControls({super.key, required this.state});
  final PlaylistState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(playerControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PositionBar(
          durationStream: state.durationStream,
          positionStream: state.positionStream,
          onSeek: notifier.seekTo,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'السابق',
              icon: const Icon(Icons.skip_previous_rounded, size: 28),
              onPressed: notifier.previous,
            ),
            const SizedBox(width: 8),
            StreamBuilder<bool>(
              stream: state.playingStream,
              initialData: false,
              builder: (_, snap) {
                final playing = snap.data ?? false;
                return FilledButton.tonalIcon(
                  onPressed: playing ? notifier.pause : notifier.play,
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 28,
                  ),
                  label: Text(playing ? 'إيقاف مؤقت' : 'تشغيل'),
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'التالي',
              icon: const Icon(Icons.skip_next_rounded, size: 28),
              onPressed: notifier.next,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            _SpeedMenu(onSelect: (v) => notifier.seekTo(const Duration())),
            StreamBuilder<LoopMode>(
              stream: state.loopModeStream,
              initialData: LoopMode.off,
              builder: (_, snap) {
                final on = (snap.data ?? LoopMode.off) != LoopMode.off;
                return _OutlinedIcon(
                  text: on ? 'التكرار: يعمل' : 'التكرار: متوقف',
                  icon: on ? Icons.repeat_on_rounded : Icons.repeat_rounded,
                  onTap: notifier.toggleLoop,
                );
              },
            ),
            StreamBuilder<double>(
              stream: state.volumeStream,
              initialData: 1.0,
              builder: (_, snap) {
                final muted = (snap.data ?? 1.0) == 0.0;
                return _OutlinedIcon(
                  text: muted ? 'صامت: يعمل' : 'صامت: متوقف',
                  icon: muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  onTap: notifier.toggleMute,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'المسارات: ${state.total}',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _OutlinedIcon extends StatelessWidget {
  const _OutlinedIcon({
    required this.text,
    required this.icon,
    required this.onTap,
  });
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
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
          .map((v) => PopupMenuItem<double>(value: v, child: Text('${v}x')))
          .toList(),
      child: Chip(
        label: Text('السرعة ${_speed}x'),
        avatar: const Icon(Icons.speed_rounded, size: 18),
      ),
    );
  }
}
