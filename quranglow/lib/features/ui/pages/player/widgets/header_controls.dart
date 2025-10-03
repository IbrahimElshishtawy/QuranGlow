// lib/features/ui/pages/player/widgets/header_controls.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';

class HeaderControls extends ConsumerWidget {
  const HeaderControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editions = ref.watch(audioEditionsProvider);
    final ed = ref.watch(editionIdProvider);
    final chapter = ref.watch(chapterProvider);

    return Row(
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
                return const Text('لا توجد إصدارات صوتية متاحة');
              return DropdownButtonFormField<String>(
                value: ed,
                decoration: const InputDecoration(
                  labelText: 'اختيار القارئ',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                items: items.map((m) {
                  final id = (m['identifier'] ?? '').toString();
                  final name = (m['name'] ?? m['englishName'] ?? id).toString();
                  return DropdownMenuItem(value: id, child: Text(name));
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(playerControllerProvider.notifier)
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
              ref.read(playerControllerProvider.notifier).changeChapter(n);
            },
          ),
        ),
      ],
    );
  }
}
