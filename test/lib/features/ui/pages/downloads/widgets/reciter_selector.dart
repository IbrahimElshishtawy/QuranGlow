// lib/features/ui/pages/downloads/widgets/reciter_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/core/di/providers.dart';
import 'package:test/features/ui/pages/downloads/controller/download_controller.dart'
    show downloadControllerProvider;
import 'package:test/features/ui/routes/app_routes.dart';

class ReciterSelector extends ConsumerStatefulWidget {
  final List<Map<String, String>> editions;
  final String? value;
  final int surah;
  final ValueChanged<String?>? onChanged;

  const ReciterSelector({
    super.key,
    required this.editions,
    this.value,
    required this.surah,
    this.onChanged,
  });

  @override
  ConsumerState<ReciterSelector> createState() => _ReciterSelectorState();
}

class _ReciterSelectorState extends ConsumerState<ReciterSelector> {
  late String? _selected;
  List<String> _ayahUrls = [];
  final Set<int> _selectedAyahs = {};
  bool _selectAllAyahs = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
    _loadAyahsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ReciterSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.surah != widget.surah) {
      _selected = widget.value;
      _ayahUrls = [];
      _selectedAyahs.clear();
      _selectAllAyahs = false;
      _loadAyahsIfNeeded();
    }
  }

  Future<void> _loadAyahsIfNeeded() async {
    if (_selected == null || _selected!.isEmpty) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(quranServiceProvider);
      final urls = await service.getSurahAudioUrls(_selected!, widget.surah);
      if (mounted) {
        setState(() {
          _ayahUrls = urls.toList();
          _selectedAyahs.clear();
          _selectAllAyahs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ جلب الآيات: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleAyah(int index, bool? v) {
    setState(() {
      if (v == true) {
        _selectedAyahs.add(index);
      } else {
        _selectedAyahs.remove(index);
      }
      _selectAllAyahs = _selectedAyahs.length == _ayahUrls.length;
    });
  }

  void _toggleSelectAll(bool? v) {
    setState(() {
      _selectAllAyahs = v == true;
      _selectedAyahs.clear();
      if (_selectAllAyahs) {
        for (int i = 0; i < _ayahUrls.length; i++) {
          _selectedAyahs.add(i);
        }
      }
    });
  }

  Future<void> _downloadSelected() async {
    if (_selected == null || _selected!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر قارئًا أولاً')));
      return;
    }
    if (_ayahUrls.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا توجد آيات محمّلة')));
      return;
    }
    if (_selectedAyahs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر آية واحدة على الأقل')));
      return;
    }

    setState(() => _busy = true);
    final downloader = ref.read(downloadControllerProvider.notifier);
    try {
      final selectedUrls = _selectedAyahs.toList()..sort();
      final urls = selectedUrls.map((i) => _ayahUrls[i]).toList();

      await downloader.downloadSurah(
        surah: widget.surah,
        reciterId: _selected!,
        ayahUrls: urls,
      );

      if (mounted) Navigator.of(context).pushNamed(AppRoutes.downloadsLibrary);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء البدء: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _selected,
          decoration: const InputDecoration(
            labelText: 'القارئ',
            border: OutlineInputBorder(),
          ),
          items: widget.editions
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e['id'],
                  child: Text(
                    '${e['name']} (${e['id']})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              _selected = v;
              _ayahUrls = [];
              _selectedAyahs.clear();
              _selectAllAyahs = false;
            });
            if (widget.onChanged != null) widget.onChanged!(v);
            _loadAyahsIfNeeded();
          },
          validator: (v) => (v == null || v.isEmpty) ? 'اختر قارئًا' : null,
        ),
        const SizedBox(height: 8),

        // حالة التحميل أو عدم وجود آيات
        if (_busy) const LinearProgressIndicator(),
        if (!_busy &&
            _selected != null &&
            _selected!.isNotEmpty &&
            _ayahUrls.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'لم تُحمّل بعد لائحة الآيات. حاول إلغاء اختيار القارئ ثم اختياره مرة أخرى.',
            ),
          ),

        // أدوات التحديد والتنزيل
        if (_ayahUrls.isNotEmpty) ...[
          Row(
            children: [
              Checkbox(value: _selectAllAyahs, onChanged: _toggleSelectAll),
              const SizedBox(width: 8),
              const Text('تحديد الكل آيات'),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _busy ? null : _downloadSelected,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download),
                label: const Text('تنزيل المحدد'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 280,
            child: ListView.separated(
              itemCount: _ayahUrls.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (c, idx) {
                final selected = _selectedAyahs.contains(idx);
                return ListTile(
                  dense: true,
                  title: Text(
                    'آية ${idx + 1}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _ayahUrls[idx],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (v) => _toggleAyah(idx, v),
                  ),
                  onTap: () => _toggleAyah(idx, !selected),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
