import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/settings/presentation/widgets/section_header.dart';

class TasbihSection extends ConsumerWidget {
  const TasbihSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final cs = Theme.of(context).colorScheme;

    return settings.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('خطأ: $error'),
      ),
      data: (st) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader('التسبيح'),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.flag_rounded),
                  title: const Text('الهدف لكل دورة'),
                  subtitle: Text('${st.tasbihTarget} تسبيحة'),
                  trailing: DropdownButton<int>(
                    value: st.tasbihTarget,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) async {
                      if (value == null) return;
                      await ref
                          .read(settingsProvider.notifier)
                          .setTasbihTarget(value);
                    },
                    items: const [33, 66, 99, 100]
                        .map(
                          (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: st.tasbihVibrate,
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('اهتزاز عند العد'),
                  subtitle: const Text('نبضة خفيفة مع كل تسبيحة'),
                  onChanged: (value) async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setTasbihVibrate(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: st.tasbihSound,
                  secondary: const Icon(Icons.music_note_rounded),
                  title: const Text('صوت عند العد'),
                  subtitle: const Text('إشارة صوتية قصيرة عند كل ضغطة'),
                  onChanged: (value) async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setTasbihSound(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
