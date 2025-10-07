// lib/features/ui/pages/downloads/downloads_page.dart
// ignore_for_file: deprecated_member_use, unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/downloads/controller/download_controller.dart';
import 'package:quranglow/features/ui/pages/downloads/widgets/reciter_selector.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  final bool embedded;
  const DownloadsPage({super.key, this.embedded = true});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  final _formKey = GlobalKey<FormState>();
  int _surah = 18;
  String? _reciterId;
  bool _loading = true;
  List<Map<String, String>> _editions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = ref.read(quranServiceProvider);
      final raw = await service.listAudioEditions();

      final editions = raw
          .map<Map<String, String>>((e) {
            final m = Map<String, dynamic>.from(e as Map);
            final id = (m['identifier'] ?? m['id'] ?? '').toString();
            final name = (m['name'] ?? m['englishName'] ?? id).toString();
            return {'id': id, 'name': name};
          })
          .where((e) => (e['id'] ?? '').isNotEmpty)
          .toList();

      editions.sort((a, b) {
        final an = (a['name'] ?? '').toLowerCase();
        final bn = (b['name'] ?? '').toLowerCase();
        final ap = (an.contains('ar.') || an.contains('arabic')) ? 0 : 1;
        final bp = (bn.contains('ar.') || bn.contains('arabic')) ? 0 : 1;
        return ap.compareTo(bp);
      });

      setState(() {
        _editions = editions;
        _reciterId = editions.isNotEmpty ? editions.first['id'] : null;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذّر جلب القرّاء')));
      }
    }
  }

  // يُفتح bottom sheet لجلب لائحة الآيات للسورة+قارئ محدد (بدون تنقل/route)
  Future<void> _showAyahPicker(int surah) async {
    if (_reciterId == null || _reciterId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر قارئًا أولًا')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: _AyahPickerSheet(reciterId: _reciterId!, surah: surah),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height - kToolbarHeight - 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _surah,
                      decoration: const InputDecoration(
                        labelText: 'اختر السورة',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        114,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                            'سورة رقم ${i + 1}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() => _surah = v ?? 1);
                        // هنا: لا ننتقل لصفحة أخرى. نعرض bottom sheet لآيات السورة.
                        _showAyahPicker(v ?? 1);
                      },
                    ),
                    const SizedBox(height: 12),
                    ReciterSelector(
                      editions: _editions,
                      value: _reciterId,
                      surah: _surah,
                      onChanged: (v) => setState(() => _reciterId = v),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // بديل: فتح صفحة تنزيل مفردة إذا احتجت ذلك
                          if (_reciterId == null || _reciterId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('اختر قارئًا')),
                            );
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            AppRoutes.downloadDetail,
                            arguments: {
                              'surah': _surah,
                              'reciterId': _reciterId!,
                            },
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('ابدأ تنزيل سورة مفردة'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'عند اختيار السورة ستفتح قائمة الآيات للاختيار والتنزيل مباشرة.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: widget.embedded
            ? null
            : AppBar(
                title: const Text('التنزيلات'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
        body: content,
      ),
    );
  }
}

/// Bottom sheet widget: يجلب روابط الآيات ويعرضها مع اختيار وتنزيل.
class _AyahPickerSheet extends ConsumerStatefulWidget {
  final String reciterId;
  final int surah;
  const _AyahPickerSheet({
    required this.reciterId,
    required this.surah,
    super.key,
  });

  @override
  ConsumerState<_AyahPickerSheet> createState() => _AyahPickerSheetState();
}

class _AyahPickerSheetState extends ConsumerState<_AyahPickerSheet> {
  bool _loading = true;
  List<String> _ayahUrls = [];
  final Set<int> _selected = {};
  bool _selectAll = false;
  bool _busy = false;

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
      if (mounted) {
        setState(() {
          _ayahUrls = urls.toList();
          _selected.clear();
          _selectAll = false;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ جلب الآيات: ${e.toString()}')),
        );
      }
    }
  }

  void _toggle(int idx, bool? v) {
    setState(() {
      if (v == true) {
        _selected.add(idx);
      } else {
        _selected.remove(idx);
      }
      _selectAll = _selected.length == _ayahUrls.length;
    });
  }

  void _toggleAll(bool? v) {
    setState(() {
      _selectAll = v == true;
      _selected.clear();
      if (_selectAll) {
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
      ).showSnackBar(const SnackBar(content: Text('اختر آيات أولاً')));
      return;
    }
    setState(() => _busy = true);
    try {
      final downloader = ref.read(downloadControllerProvider.notifier);
      final indexes = _selected.toList()..sort();
      final urls = indexes.map((i) => _ayahUrls[i]).toList();

      await downloader.downloadSurah(
        surah: widget.surah,
        reciterId: widget.reciterId,
        ayahUrls: urls,
      );

      // إغلاق الـ sheet ثم الانتقال للمكتبة
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(AppRoutes.downloadsLibrary);
      }
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
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'آيات سورة ${'' /* يمكن إضافة اسم السورة إن متاح */}',
                  ),
                  const Spacer(),
                  Checkbox(value: _selectAll, onChanged: _toggleAll),
                  const SizedBox(width: 8),
                  const Text('تحديد الكل'),
                ],
              ),
              const Divider(),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_loading && _ayahUrls.isEmpty)
                const Expanded(child: Center(child: Text('لا توجد آيات'))),
              if (!_loading && _ayahUrls.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    itemCount: _ayahUrls.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (c, idx) {
                      final sel = _selected.contains(idx);
                      return ListTile(
                        title: Text('آية ${idx + 1}'),
                        subtitle: Text(
                          _ayahUrls[idx],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Checkbox(
                          value: sel,
                          onChanged: (v) => _toggle(idx, v),
                        ),
                        onTap: () => _toggle(idx, !sel),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Row(
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
                      label: const Text('تنزيل المحدد'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
