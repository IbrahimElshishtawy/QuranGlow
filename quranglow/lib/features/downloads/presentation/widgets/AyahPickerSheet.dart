import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart'
    hide downloadControllerProvider;
import 'package:quranglow/features/downloads/presentation/pages/surah_files_page.dart';
import 'package:quranglow/features/downloads/presentation/providers/download_controller.dart';
import 'package:quranglow/features/downloads/presentation/widgets/audio_loading_state.dart';

class AyahPickerSheet extends ConsumerStatefulWidget {
  const AyahPickerSheet({
    required this.reciterId,
    required this.surah,
    super.key,
  });

  final String reciterId;
  final int surah;

  @override
  ConsumerState<AyahPickerSheet> createState() => AyahPickerSheetState();
}

class AyahPickerSheetState extends ConsumerState<AyahPickerSheet> {
  bool _loading = true;
  List<String> _ayahUrls = [];
  final Set<int> _selected = <int>{};
  bool _busy = false;
  bool _all = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError =
            'تعذر تحميل الروابط الصوتية. تحقق من الإنترنت ثم أعد المحاولة.';
      });
    }
  }

  void _toggle(int index, bool value) {
    setState(() {
      if (value) {
        _selected.add(index);
      } else {
        _selected.remove(index);
      }
      _all = _selected.length == _ayahUrls.length;
    });
  }

  void _toggleAll(bool value) {
    setState(() {
      _all = value;
      _selected.clear();
      if (value) {
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
      ).showSnackBar(const SnackBar(content: Text('اختر آيات أولًا.')));
      return;
    }

    setState(() => _busy = true);
    final downloader = ref.read(downloadControllerProvider.notifier);
    final idx = _selected.toList()..sort();
    final items = <AyahDownload>[
      for (final i in idx) AyahDownload(ayah: i + 1, url: _ayahUrls[i]),
    ];

    final success = await downloader.downloadAyat(
      surah: widget.surah,
      reciterId: widget.reciterId,
      items: items,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    final downloadState = ref.read(downloadControllerProvider);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            downloadState.message ?? 'تعذر إكمال التحميل. حاول مرة أخرى.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SurahFilesPage(reciterId: widget.reciterId, surah: widget.surah),
      ),
    );
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
                ? const Center(child: AudioLoadingState.loading())
                : _loadError != null
                ? Center(
                    child: AudioLoadingState.error(
                      message: _loadError!,
                      onAction: _load,
                    ),
                  )
                : _ayahUrls.isEmpty
                ? Center(
                    child: AudioLoadingState.empty(
                      message: 'لا توجد آيات صوتية متاحة لهذه السورة الآن.',
                      onAction: _load,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _ayahUrls.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
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
