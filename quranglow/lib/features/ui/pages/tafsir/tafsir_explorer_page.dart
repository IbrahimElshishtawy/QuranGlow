// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';

class TafsirExplorerPage extends ConsumerWidget {
  const TafsirExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final editions = ref.watch(tafsirEditionsProvider);

    Future<void> _refresh() async {
      await ref.refresh(tafsirEditionsProvider.future);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التفسير'), centerTitle: true),
        body: editions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (list) => RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = list[i];
                final id = item['id']!;
                final name = item['name']!;
                return ListTile(
                  title: Text(name),
                  subtitle: Text(
                    'المعرّف: $id',
                    style: TextStyle(color: cs.outline),
                  ),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TafsirDetailPage(editionId: id, editionName: name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TafsirDetailPage extends ConsumerStatefulWidget {
  const TafsirDetailPage({
    super.key,
    required this.editionId,
    required this.editionName,
  });
  final String editionId;
  final String editionName;

  @override
  ConsumerState<TafsirDetailPage> createState() => _TafsirDetailPageState();
}

class _TafsirDetailPageState extends ConsumerState<TafsirDetailPage> {
  int _surah = 1;
  int _ayah = 1;

  @override
  Widget build(BuildContext context) {
    final tafsir = ref.watch(
      tafsirForAyahProvider((_surah, _ayah, widget.editionId)),
    );

    Future<void> _pick() async {
      final sCtrl = TextEditingController(text: _surah.toString());
      final aCtrl = TextEditingController(text: _ayah.toString());
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('اختر سورة/آية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'سورة'),
                keyboardType: TextInputType.number,
                controller: sCtrl,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'آية'),
                keyboardType: TextInputType.number,
                controller: aCtrl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('عرض'),
            ),
          ],
        ),
      );
      if (ok == true) {
        setState(() {
          _surah = int.tryParse(sCtrl.text) ?? _surah;
          _ayah = int.tryParse(aCtrl.text) ?? _ayah;
        });
        // إعادة الجلب
        ref.refresh(
          tafsirForAyahProvider((_surah, _ayah, widget.editionId)).future,
        );
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editionName),
          actions: [IconButton(onPressed: _pick, icon: const Icon(Icons.tune))],
        ),
        body: tafsir.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (text) => RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(
                tafsirForAyahProvider((_surah, _ayah, widget.editionId)).future,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'سورة $_surah • آية $_ayah',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  text.isEmpty ? 'لا يوجد نص.' : text,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
