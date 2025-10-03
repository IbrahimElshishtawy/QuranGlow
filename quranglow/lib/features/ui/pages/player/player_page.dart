// lib/features/ui/pages/player/player_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/position_bar.dart'
    as widgets;

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});
  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final editions = ref.watch(audioEditionsProvider);
    final ed = ref.watch(editionIdProvider);
    final chapter = ref.watch(chapterProvider);
    final ctrl = ref.watch(playerControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('المشغّل'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: cs.onSurface,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary.withOpacity(.12),
                    cs.surfaceContainerHighest.withOpacity(.25),
                    cs.surface,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final kb = MediaQuery.of(context).viewInsets.bottom;
                  return ListView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + kb),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: editions.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text('خطأ بالإصدارات: $e'),
                              data: (list) {
                                final items = list
                                    .whereType<Map>()
                                    .map((m) => Map<String, dynamic>.from(m))
                                    .toList();
                                if (items.isEmpty)
                                  return const Text(
                                    'لا توجد إصدارات صوتية متاحة',
                                  );
                                return DropdownButtonFormField<String>(
                                  value: ed,
                                  decoration: const InputDecoration(
                                    labelText: 'اختيار القارئ',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  isExpanded: true,
                                  items: items.map((m) {
                                    final id = (m['identifier'] ?? '')
                                        .toString();
                                    final name =
                                        (m['name'] ?? m['englishName'] ?? id)
                                            .toString();
                                    return DropdownMenuItem(
                                      value: id,
                                      child: Text(name),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      ref
                                          .read(
                                            playerControllerProvider.notifier,
                                          )
                                          .changeEdition(v);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              initialValue: chapter.toString(),
                              decoration: const InputDecoration(
                                labelText: 'السورة',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (v) {
                                final n = int.tryParse(v) ?? chapter;
                                ref
                                    .read(playerControllerProvider.notifier)
                                    .changeChapter(n);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh.withOpacity(.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cs.outlineVariant.withOpacity(.4),
                              ),
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [cs.primary, cs.secondary],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'سورة $chapter',
                                        style: t.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text('القارئ: $ed', style: t.bodyMedium),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _Pill(text: 'تشغيل متصل'),
                                          const SizedBox(width: 8),
                                          _Pill(text: 'جودة عادية'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.10),

                      Center(
                        child: ctrl.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تعذر التحميل'),
                              const SizedBox(height: 8),
                              Text(
                                '$e',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          data: (s) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widgets.PositionBar(
                                durationStream: s.durationStream,
                                positionStream: s.positionStream,
                                onSeek: ref
                                    .read(playerControllerProvider.notifier)
                                    .seekTo,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _RoundIconButton(
                                    icon: Icons.skip_previous_rounded,
                                    onTap: () => ref
                                        .read(playerControllerProvider.notifier)
                                        .previous(),
                                  ),
                                  const SizedBox(width: 12),
                                  StreamBuilder<bool>(
                                    stream: s.playingStream,
                                    initialData: false,
                                    builder: (_, snap) {
                                      final playing = snap.data ?? false;
                                      return ScaleTransition(
                                        scale: Tween(begin: 0.98, end: 1.04)
                                            .animate(
                                              CurvedAnimation(
                                                parent: _pulse,
                                                curve: Curves.easeInOut,
                                              ),
                                            ),
                                        child: FilledButton.tonalIcon(
                                          onPressed: () => playing
                                              ? ref
                                                    .read(
                                                      playerControllerProvider
                                                          .notifier,
                                                    )
                                                    .pause()
                                              : ref
                                                    .read(
                                                      playerControllerProvider
                                                          .notifier,
                                                    )
                                                    .play(),
                                          icon: Icon(
                                            playing
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 30,
                                          ),
                                          label: Text(
                                            playing ? 'إيقاف مؤقت' : 'تشغيل',
                                          ),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 22,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _RoundIconButton(
                                    icon: Icons.skip_next_rounded,
                                    onTap: () => ref
                                        .read(playerControllerProvider.notifier)
                                        .next(),
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
                                    onSelect: (v) => ref
                                        .read(playerControllerProvider.notifier)
                                        .seekTo(const Duration()),
                                  ),
                                  _OutlinedIcon(
                                    text: 'تكرار',
                                    icon: Icons.repeat_rounded,
                                    onTap: () {},
                                  ),
                                  _OutlinedIcon(
                                    text: 'صامت',
                                    icon: Icons.volume_off_rounded,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(icon, size: 26),
      ),
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
