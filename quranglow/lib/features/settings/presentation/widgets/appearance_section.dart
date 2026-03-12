import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/app_settings.dart';
import 'package:quranglow/features/settings/presentation/widgets/font_scale_dialog.dart';
import 'package:quranglow/features/settings/presentation/widgets/readers_sheet.dart';
import 'package:quranglow/features/settings/presentation/widgets/section_header.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);

    return s.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('خطأ: $e')),
      data: (st) => Column(
        children: [
          const SectionHeader('المظهر والقراءة'),
          SwitchListTile(
            title: const Text('الوضع الداكن'),
            value: st.darkMode,
            onChanged: (v) => ref.read(settingsProvider.notifier).setDark(v),
          ),
          ListTile(
            title: const Text('حجم الخط'),
            subtitle: Text(st.fontScale.toStringAsFixed(2)),
            trailing: const Icon(Icons.chevron_left),
            onTap: () async {
              final v = await showDialog<double>(
                context: context,
                builder: (_) => FontScaleDialog(value: st.fontScale),
              );
              if (v != null) {
                await ref.read(settingsProvider.notifier).setFontScale(v);
              }
            },
          ),
          ListTile(
            title: const Text('اختيار القارئ'),
            subtitle: Text(st.readerEditionId),
            trailing: const Icon(Icons.chevron_left),
            onTap: () async {
              final chosen = await showModalBottomSheet<String>(
                context: context,
                builder: (_) => const ReadersSheet(),
              );
              if (chosen != null) {
                await ref.read(settingsProvider.notifier).setReader(chosen);
              }
            },
          ),
          ListTile(
            title: const Text('تنزيل الصوت'),
            subtitle: Text(_downloadModeLabel(st.audioDownloadMode)),
            trailing: DropdownButton<AudioDownloadMode>(
              value: st.audioDownloadMode,
              onChanged: (value) async {
                if (value == null) return;
                await ref
                    .read(settingsProvider.notifier)
                    .setAudioDownloadMode(value);
              },
              items: const [
                DropdownMenuItem(
                  value: AudioDownloadMode.fullSurah,
                  child: Text('السورة كاملة'),
                ),
                DropdownMenuItem(
                  value: AudioDownloadMode.selectedAyat,
                  child: Text('اختيار آيات'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _downloadModeLabel(AudioDownloadMode mode) {
    switch (mode) {
      case AudioDownloadMode.fullSurah:
        return 'تنزيل السورة كاملة مباشرة';
      case AudioDownloadMode.selectedAyat:
        return 'فتح قائمة لاختيار آيات محددة';
    }
  }
}
