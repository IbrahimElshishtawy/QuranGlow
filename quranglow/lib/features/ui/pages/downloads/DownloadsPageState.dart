// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/downloads/downloads_page.dart';
import 'package:quranglow/features/ui/pages/downloads/widgets/AyahPickerSheet.dart';
import 'package:quranglow/features/ui/pages/downloads/widgets/HeaderCard.dart';
import 'package:quranglow/features/ui/pages/downloads/widgets/SectionCard.dart';
import 'package:quranglow/features/ui/pages/downloads/widgets/reciter_selector.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class DownloadsPageState extends ConsumerState<DownloadsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _surah = 18;
  String? _reciterId;
  bool _loading = true;
  List<Map<String, String>> _editions = const [];

  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeInOut,
  );

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
        return ap != bp
            ? ap.compareTo(bp)
            : (a['name'] ?? '').compareTo(b['name'] ?? '');
      });

      if (!mounted) return;
      setState(() {
        _editions = editions;
        _reciterId = editions.isNotEmpty ? editions.first['id'] : null;
        _loading = false;
      });
      _ac.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذّر جلب القرّاء')));
    }
  }

  Future<void> _showAyahPicker(int surah) async {
    if ((_reciterId ?? '').isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر قارئًا أولًا')));
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: AyahPickerSheet(reciterId: _reciterId!, surah: surah),
        );
      },
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary.withOpacity(.06), cs.surface],
            ),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fade,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      HeaderCard_D(),
                      const SizedBox(height: 12),
                      SectionCard(
                        title: 'اختيار السورة والقارئ',
                        subtitle:
                            'حدّد السورة ثم اختر القارئ. يمكن تحديد آيات بعينها.',
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                value: _surah,
                                decoration: const InputDecoration(
                                  labelText: 'السورة',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: List.generate(
                                  114,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('سورة رقم ${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  final s = (v ?? 1).clamp(1, 114);
                                  setState(() => _surah = s);
                                  _showAyahPicker(s);
                                },
                              ),
                              const SizedBox(height: 12),
                              ReciterSelector(
                                editions: _editions,
                                value: _reciterId,
                                surah: _surah,
                                onChanged: (v) =>
                                    setState(() => _reciterId = v),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // بطاقة الإجراءات
                      SectionCard(
                        title: 'إجراءات سريعة',
                        subtitle: 'تنزيل السورة كاملة أو فتح المكتبة.',
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  if ((_reciterId ?? '').isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('اختر قارئًا'),
                                      ),
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
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('تنزيل السورة'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.downloadsLibrary,
                                ),
                                icon: const Icon(Icons.library_music),
                                label: const Text('المكتبة'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Opacity(
                        opacity: .75,
                        child: Text(
                          'عند اختيار السورة تُفتح قائمة لاختيار آيات محدّدة للتنزيل.',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
