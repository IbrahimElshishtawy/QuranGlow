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
    final quran = ref.watch(quranAllProvider('quran-uthmani'));

    editions.whenData((list) {
      if ((_editionId == null || _editionId!.isEmpty) && list.isNotEmpty) {
        setState(() {
          _editionId = list.first['id']!;
          _editionName = list.first['name']!;
        });
      }
    });

    final AsyncValue<String> tafsir = (_editionId == null)
        ? const AsyncValue<String>.loading()
        : ref.watch(tafsirForAyahProvider((_surah, _ayah, _editionId!)));
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
            SelectionCard(
              editions: editions,
              quranAll: quran,
              editionId: _editionId,
              surah: _surah,
              ayah: _ayah,
              onEditionChange: (id, name) {
                setState(() {
                  _editionId = id;
                  _editionName = name;
                });
                ref.refresh(tafsirForAyahProvider((_surah, _ayah, id)).future);
              },
              onSurahChange: (v, maxAyat) {
                setState(() {
                  _surah = v;
                  _ayah = _ayah.clamp(1, maxAyat);
                });
                if (_editionId != null) {
                  ref.refresh(
                    tafsirForAyahProvider((_surah, _ayah, _editionId!)).future,
                  );
                }
              },
              onAyahChange: (v) {
                setState(() => _ayah = v);
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
