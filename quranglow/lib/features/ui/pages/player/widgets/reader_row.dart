import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderRow extends StatelessWidget {
  const ReaderRow({
    super.key,
    required this.editions,
    required this.selectedEditionId,
    required this.initialChapter,
    required this.onEditionChanged,
    required this.onChapterSubmitted,
  });

  final AsyncValue<List<dynamic>> editions;
  final String selectedEditionId;
  final int initialChapter;
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
                initialValue: selectedEditionId,
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
        SizedBox(
          width: 120,
          child: TextFormField(
            initialValue: initialChapter.toString(),
            decoration: const InputDecoration(
              labelText: 'السورة',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onFieldSubmitted: onChapterSubmitted,
          ),
        ),
      ],
    );
  }
}
