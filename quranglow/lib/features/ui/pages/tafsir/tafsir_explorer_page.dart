// lib/features/ui/pages/tafsir/tafsir_reader_page.dart
// ignore_for_file: unused_result
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/features/ui/pages/tafsir/widget/ayah_card.dart';
import 'package:quranglow/features/ui/pages/tafsir/widget/selection_card.dart';
import 'package:quranglow/features/ui/pages/tafsir/widget/tafsir_card.dart';

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
    final editions = ref.watch(tafsirEditionsProvider);

    editions.whenData((list) {
      if ((_editionId == null || _editionId!.isEmpty) && list.isNotEmpty) {
        setState(() {
          _editionId = list.first['id']!;
          _editionName = list.first['name']!;
        });
      }
    });

    // حدد النوع صراحةً
    final AsyncValue<String> tafsir = (_editionId == null)
        ? const AsyncValue<String>.loading()
        : ref.watch(tafsirForAyahProvider((_surah, _ayah, _editionId!)));

    // سورة واحدة فقط
    final surahAsync = (_editionId == null)
        ? const AsyncValue<Surah>.loading()
        : ref.watch(quranSurahProvider((_surah, 'quran-uthmani')));

    String surahName = 'سورة $_surah';
    String ayahText = '';
    int maxAyat = 286; // افتراضي
    surahAsync.whenData((s) {
      surahName = s.name;
      maxAyat = s.ayat.length;
      if (_ayah >= 1 && _ayah <= s.ayat.length) {
        final Aya a = s.ayat[_ayah - 1];
        ayahText = a.text;
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التفسير'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SelectionCard(
              // مرّر AsyncValue للسور لاختيار السورة والآية
              editions: editions,
              // بدّل: لم نعد نحتاج كل السور، نحتاج عدد الآيات فقط من surahAsync
              quranAll: surahAsync.whenData(
                (s) => [s],
              ), // توافق بسيط مع الـWidget الحالي
              editionId: _editionId,
              surah: _surah,
              ayah: _ayah,
              onEditionChange: (id, name) {
                setState(() {
                  _editionId = id;
                  _editionName = name;
                });
                ref.refresh(tafsirForAyahProvider((_surah, _ayah, id)).future);
                ref.refresh(
                  quranSurahProvider((_surah, 'quran-uthmani')).future,
                );
              },
              onSurahChange: (v, _) {
                setState(() {
                  _surah = v;
                  _ayah = 1;
                });
                if (_editionId != null) {
                  ref.refresh(
                    quranSurahProvider((_surah, 'quran-uthmani')).future,
                  );
                  ref.refresh(
                    tafsirForAyahProvider((_surah, _ayah, _editionId!)).future,
                  );
                }
              },
              onAyahChange: (v) {
                setState(() => _ayah = v.clamp(1, maxAyat));
                if (_editionId != null) {
                  ref.refresh(
                    tafsirForAyahProvider((_surah, _ayah, _editionId!)).future,
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            AyahCard(surahName: surahName, ayah: _ayah, ayahText: ayahText),
            const SizedBox(height: 12),
            TafsirCard(tafsir: tafsir, editionName: _editionName),
          ],
        ),
      ),
    );
  }
}
