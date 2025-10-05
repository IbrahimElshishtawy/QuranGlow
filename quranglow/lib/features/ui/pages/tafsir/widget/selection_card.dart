import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/model/surah.dart';

import 'ayah_picker.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.editions,
    required this.quranAll,
    required this.editionId,
    required this.surah,
    required this.ayah,
    required this.onEditionChange,
    required this.onSurahChange,
    required this.onAyahChange,
  });

  final AsyncValue<List<Map<String, String>>> editions;
  final AsyncValue<List<Surah>> quranAll;
  final String? editionId;
  final int surah;
  final int ayah;

  final void Function(String id, String name) onEditionChange;
  final void Function(int surah, int maxAyat) onSurahChange;
  final void Function(int ayah) onAyahChange;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            editions.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطأ في التفاسير: $e'),
              data: (list) => DropdownButtonFormField<String>(
                initialValue: editionId,
                decoration: const InputDecoration(
                  labelText: 'اختيار الشيخ/التفسير',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: list
                    .map(
                      (m) => DropdownMenuItem(
                        value: m['id']!,
                        child: Text(m['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final m = list.firstWhere((e) => e['id'] == v);
                  onEditionChange(v, m['name']!);
                },
              ),
            ),
            const SizedBox(height: 12),
            quranAll.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطأ في تحميل السور: $e'),
              data: (all) {
                final fixedSurah = surah.clamp(1, all.length);
                final maxAyat = all[fixedSurah - 1].ayat.length;
                return Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: fixedSurah,
                      decoration: const InputDecoration(
                        labelText: 'اختيار السورة',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      isExpanded: true,
                      items: [
                        for (int i = 0; i < all.length; i++)
                          DropdownMenuItem(
                            value: i + 1,
                            child: Text('${all[i].name} • ${i + 1}'),
                          ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        onSurahChange(v, all[v - 1].ayat.length);
                      },
                    ),
                    const SizedBox(height: 12),
                    AyahPicker(
                      maxAyat: maxAyat,
                      ayah: ayah.clamp(1, maxAyat),
                      onAyahChange: onAyahChange,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
