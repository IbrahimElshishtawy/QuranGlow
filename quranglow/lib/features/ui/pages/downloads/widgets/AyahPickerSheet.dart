// lib/features/ui/pages/downloads/widgets/AyahPickerSheet.dart
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart'
    hide downloadControllerProvider;
import 'package:quranglow/features/ui/pages/downloads/controller/download_controller.dart';
import 'package:quranglow/features/ui/pages/downloads/surah_files_page.dart';

class AyahPickerSheet extends ConsumerStatefulWidget {
  final String reciterId;
  final int surah;
  const AyahPickerSheet({
    required this.reciterId,
    required this.surah,
    super.key,
  });

  @override
  ConsumerState<AyahPickerSheet> createState() => AyahPickerSheetState();
}

class AyahPickerSheetState extends ConsumerState<AyahPickerSheet> {
  bool _loading = true;
  List<String> _ayahUrls = [];
  final Set<int> _selected = <int>{};
  bool _busy = false;
  bool _all = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final service = ref.read(quranServiceProvider);
      final urls = await service.getSurahAudioUrls(
        widget.reciterId,
        widget.surah,
      );
      if (!mounted) return;
      setState(() {
        _ayahUrls = urls;
        _selected.clear();
        _all = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ جلب الروابط: $e')));
    }
  }

  void _toggle(int i, bool v) {
    setState(() {
      if (v) {
        _selected.add(i);
      } else {
        _selected.remove(i);
      }
      _all = _selected.length == _ayahUrls.length;
    });
  }

  void _toggleAll(bool v) {
    setState(() {
      _all = v;
      _selected.clear();
      if (v) {
        for (int i = 0; i < _ayahUrls.length; i++) {
          _selected.add(i);
        }
      }
    });
  }

  Future<void> _downloadSelected() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر آيات أولًا')));
      return;
    }
    setState(() => _busy = true);
    try {
      final downloader = ref.read(downloadControllerProvider.notifier);
      final idx = _selected.toList()..sort();
      final items = <AyahDownload>[
        for (final i in idx) AyahDownload(ayah: i + 1, url: _ayahUrls[i]),
      ];

      await downloader.downloadAyat(
        surah: widget.surah,
        reciterId: widget.reciterId,
        items: items,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              SurahFilesPage(reciterId: widget.reciterId, surah: widget.surah),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر البدء: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * .78,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'سورة ${widget.surah}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Checkbox(value: _all, onChanged: (v) => _toggleAll(v ?? false)),
                const SizedBox(width: 6),
                const Text('تحديد الكل'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _ayahUrls.isEmpty
                ? const Center(child: Text('لا توجد آيات'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _ayahUrls.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final selected = _selected.contains(i);
                      return ListTile(
                        title: Text('آية ${i + 1}'),
                        subtitle: Text(
                          _ayahUrls[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Checkbox(
                          value: selected,
                          onChanged: (v) => _toggle(i, v ?? false),
                        ),
                        onTap: () => _toggle(i, !selected),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _downloadSelected,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download),
                    label: Text(
                      _selected.isEmpty
                          ? 'تنزيل'
                          : 'تنزيل (${_selected.length})',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
