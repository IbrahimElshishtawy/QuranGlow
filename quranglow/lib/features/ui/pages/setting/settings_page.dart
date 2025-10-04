// lib/features/ui/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
        body: s.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (st) => ListView(
            children: [
              SwitchListTile(
                title: const Text('الوضع الداكن'),
                value: st.darkMode,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setDark(v),
              ),
              ListTile(
                title: const Text('حجم الخط'),
                subtitle: Text(st.fontScale.toStringAsFixed(2)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () async {
                  final v = await showDialog<double>(
                    context: context,
                    builder: (_) => _FontScaleDialog(value: st.fontScale),
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
                    builder: (_) => const _ReadersSheet(),
                  );
                  if (chosen != null) {
                    await ref.read(settingsProvider.notifier).setReader(chosen);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontScaleDialog extends StatefulWidget {
  const _FontScaleDialog({required this.value});
  final double value;
  @override
  State<_FontScaleDialog> createState() => _FontScaleDialogState();
}

class _FontScaleDialogState extends State<_FontScaleDialog> {
  late double v = widget.value;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حجم الخط'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: v,
              min: 0.8,
              max: 1.4,
              divisions: 12,
              label: v.toStringAsFixed(2),
              onChanged: (x) => setState(() => v = x),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, v),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _ReadersSheet extends ConsumerWidget {
  const _ReadersSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editions = ref.watch(audioEditionsProvider);
    return SafeArea(
      child: editions.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            Padding(padding: const EdgeInsets.all(24), child: Text('خطأ: $e')),
        data: (list) {
          return ListView.separated(
            shrinkWrap: true,
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = list[i] as Map<String, dynamic>;
              final id = (m['identifier'] ?? m['id'] ?? '').toString();
              final name = (m['name'] ?? m['englishName'] ?? id).toString();
              return ListTile(
                title: Text(name),
                subtitle: Text(id),
                onTap: () => Navigator.pop(context, id),
              );
            },
          );
        },
      ),
    );
  }
}
