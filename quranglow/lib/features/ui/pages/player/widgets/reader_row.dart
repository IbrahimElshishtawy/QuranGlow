// lib/features/ui/pages/player/widgets/reader_row.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/model/surah.dart';

class ReaderRow extends StatelessWidget {
  const ReaderRow({
    super.key,
    required this.editions,
    required this.surahs,
    required this.selectedEditionId,
    required this.selectedSurah,
    required this.onEditionChanged,
    required this.onChapterSubmitted,
  });

  final AsyncValue<List<dynamic>> editions;
  final AsyncValue<List<Surah>> surahs;
  final String selectedEditionId;
  final int selectedSurah;
  final ValueChanged<String> onEditionChanged;
  final ValueChanged<String> onChapterSubmitted;

  @override
  Widget build(BuildContext context) {
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
              if (items.isEmpty) {
                return const Text('لا توجد إصدارات صوتية متاحة');
              }

              return DropdownButtonFormField<String>(
                value: selectedEditionId,
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
                  if (v != null) onEditionChanged(v);
                },
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: surahs.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('خطأ بالسور: $e'),
            data: (list) {
              if (list.isEmpty) return const Text('لا توجد سور');
              return DropdownButtonFormField<int>(
                value: selectedSurah,
                decoration: const InputDecoration(
                  labelText: 'السورة',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                items: list.map((s) {
                  return DropdownMenuItem<int>(
                    value: s.number,
                    child: Text(s.name),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    onChapterSubmitted(v.toString());
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
