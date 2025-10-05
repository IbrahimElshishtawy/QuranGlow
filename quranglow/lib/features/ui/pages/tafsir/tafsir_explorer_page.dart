// lib/features/ui/pages/tafsir/tafsir_reader_page.dart
// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/model/aya.dart';

class TafsirReaderPage extends ConsumerStatefulWidget {
  const TafsirReaderPage({
    super.key,
    this.initialEditionId,
    this.initialEditionName,
    this.initialSurah = 1,
    this.initialAyah = 1,
  });

  final String? initialEditionId;
  final String? initialEditionName;
  final int initialSurah;
  final int initialAyah;

  @override
  ConsumerState<TafsirReaderPage> createState() => _TafsirReaderPageState();
}

class _TafsirReaderPageState extends ConsumerState<TafsirReaderPage> {
  String? _editionId;
  String? _editionName;
  int _surah = 1;
  int _ayah = 1;

  @override
  void initState() {
    super.initState();
    _editionId = widget.initialEditionId;
    _editionName = widget.initialEditionName;
    _surah = widget.initialSurah;
    _ayah = widget.initialAyah;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // المصادر
    final editions = ref.watch(
      tafsirEditionsProvider,
    ); // قائمة التفاسير (الشيوخ)
    final quran = ref.watch(
      quranAllProvider('quran-uthmani'),
    ); // نص القرآن لاستخراج الآية

    // لو ما فيه اختيار مبدئي للتفسير، عيّنه أول ما يتحمّل
    editions.whenData((list) {
      if ((_editionId == null || _editionId!.isEmpty) && list.isNotEmpty) {
        setState(() {
          _editionId = list.first['id']!;
          _editionName = list.first['name']!;
        });
      }
    });

    // مزوّد التفسير الحالي
    final tafsir = (_editionId == null)
        ? const AsyncValue.loading()
        : ref.watch(tafsirForAyahProvider((_surah, _ayah, _editionId!)));

    // استخراج اسم السورة ونص الآية (إن وُجدت البيانات)
    String surahName = 'سورة $_surah';
    String ayahText = '';
    quran.whenData((all) {
      if (_surah >= 1 && _surah <= all.length) {
        final Surah s = all[_surah - 1];
        surahName = s.name;
        if (_ayah >= 1 && _ayah <= s.ayat.length) {
          final Aya a = s.ayat[_ayah - 1];
          ayahText = a.text;
        }
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التفسير'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة الاختيارات
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: cs.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // اختيار الشيخ (نسخة التفسير)
                    editions.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('خطأ في التفاسير: $e'),
                      data: (list) {
                        return DropdownButtonFormField<String>(
                          initialValue: _editionId,
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
                            setState(() {
                              _editionId = v;
                              _editionName = m['name']!;
                            });
                            ref.refresh(
                              tafsirForAyahProvider((_surah, _ayah, v)).future,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // اختيار السورة
                    quran.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('خطأ في تحميل السور: $e'),
                      data: (all) {
                        return DropdownButtonFormField<int>(
                          initialValue: _surah.clamp(1, all.length),
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
                            final maxAyat = all[v - 1].ayat.length;
                            setState(() {
                              _surah = v;
                              _ayah = _ayah.clamp(1, maxAyat);
                            });
                            if (_editionId != null) {
                              ref.refresh(
                                tafsirForAyahProvider((
                                  _surah,
                                  _ayah,
                                  _editionId!,
                                )).future,
                              );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // اختيار الآية
                    quran.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (all) {
                        final maxAyat = (_surah >= 1 && _surah <= all.length)
                            ? all[_surah - 1].ayat.length
                            : 286; // افتراضي
                        return Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _ayah.toDouble().clamp(
                                  1,
                                  maxAyat.toDouble(),
                                ),
                                min: 1,
                                max: maxAyat.toDouble(),
                                divisions: maxAyat - 1,
                                label: 'آية $_ayah من $maxAyat',
                                onChanged: (x) =>
                                    setState(() => _ayah = x.round()),
                                onChangeEnd: (x) {
                                  if (_editionId != null) {
                                    ref.refresh(
                                      tafsirForAyahProvider((
                                        _surah,
                                        _ayah,
                                        _editionId!,
                                      )).future,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 64,
                              child: TextFormField(
                                key: ValueKey('ayah_$_surah'),
                                initialValue: _ayah.toString(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'الآية',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onFieldSubmitted: (v) {
                                  final n = int.tryParse(v) ?? _ayah;
                                  setState(() => _ayah = n.clamp(1, maxAyat));
                                  if (_editionId != null) {
                                    ref.refresh(
                                      tafsirForAyahProvider((
                                        _surah,
                                        _ayah,
                                        _editionId!,
                                      )).future,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // بطاقة نص الآية
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$surahName • آية $_ayah',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ayahText.isEmpty ? '—' : ayahText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // بطاقة نص التفسير
            tafsir.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _ErrorCard(msg: 'خطأ في جلب التفسير: $e'),
              data: (text) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editionName?.isNotEmpty == true
                            ? _editionName!
                            : 'التفسير',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (text.isEmpty) ? 'لا يوجد نص.' : text,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(height: 1.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.msg});
  final String msg;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(msg, style: TextStyle(color: cs.onErrorContainer)),
      ),
    );
  }
}
