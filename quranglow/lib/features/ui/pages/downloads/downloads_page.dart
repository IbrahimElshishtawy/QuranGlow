// lib/features/ui/pages/downloads/downloads_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
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

  void _startDownload() {
    if (!_formKey.currentState!.validate()) return;
    if (_reciterId == null || _reciterId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر قارئًا')));
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.downloadDetail,
      arguments: {'surah': _surah, 'reciterId': _reciterId!},
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
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: _surah,
                    decoration: const InputDecoration(
                      labelText: 'السورة',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      114,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('سورة رقم ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) => setState(() => _surah = v ?? 1),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _reciterId,
                    decoration: const InputDecoration(
                      labelText: 'القارئ',
                      border: OutlineInputBorder(),
                    ),
                    items: _editions
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e['id'],
                            child: Text('${e['name']} (${e['id']})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _reciterId = v),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'اختر قارئًا' : null,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _startDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('ابدأ التنزيل'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيتم تنزيل كل آيات السورة المختارة بصوت القارئ المحدد.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
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
