// lib/features/ui/pages/downloads/download_detail_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/data/surah_names_ar.dart';
import 'package:quranglow/features/ui/pages/downloads/controller/download_controller.dart'
    hide downloadControllerProvider;
import 'package:quranglow/features/ui/pages/downloads/surah_files_page.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class DownloadDetailPage extends ConsumerStatefulWidget {
  const DownloadDetailPage({
    super.key,
    required this.surah,
    required this.reciterId,
  });
  final int surah;
  final String reciterId;

  @override
  ConsumerState<DownloadDetailPage> createState() => _DownloadDetailPageState();
}

class _DownloadDetailPageState extends ConsumerState<DownloadDetailPage> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _kickoff();
  }

  Future<void> _kickoff() async {
    if (_started) return;
    _started = true;

    final service = ref.read(quranServiceProvider);
    final urls = await service.getSurahAudioUrls(
      widget.reciterId,
      widget.surah,
    );

    // استخدم التوقيع الجديد للحفاظ على أرقام الآيات في أسماء الملفات
    final items = [
      for (int i = 0; i < urls.length; i++)
        AyahDownload(ayah: i + 1, url: urls[i]),
    ];
    await ref
        .read(downloadControllerProvider.notifier)
        .downloadAyat(
          surah: widget.surah,
          reciterId: widget.reciterId,
          items: items,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final st = ref.watch(downloadControllerProvider);

    ref.listen(downloadControllerProvider, (prev, next) {
      if (next.status == DownloadStatus.done && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SurahFilesPage(
              reciterId: widget.reciterId,
              surah: widget.surah,
            ),
          ),
        );
      }
    });

    final name = (widget.surah >= 1 && widget.surah < kSurahNamesAr.length)
        ? kSurahNamesAr[widget.surah]
        : widget.surah.toString();

    final statusText = switch (st.status) {
      DownloadStatus.running => 'جاري التنزيل…',
      DownloadStatus.done => 'اكتمل التنزيل',
      DownloadStatus.error => 'خطأ: ${st.message ?? ''}',
      DownloadStatus.cancelled => 'تم الإلغاء',
      _ => 'جاهز',
    };

    final progress = switch (st.status) {
      DownloadStatus.running || DownloadStatus.done => st.progress,
      _ => null,
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تنزيل سورة'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'المكتبة',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.downloadsLibrary),
              icon: const Icon(Icons.library_music),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(.12),
                    child: Text(
                      '${widget.surah}',
                      style: TextStyle(color: cs.primary),
                    ),
                  ),
                  title: Text('سورة $name', overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    'القارئ: ${widget.reciterId}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: cs.primary.withOpacity(.12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                  if (st.total > 0) Text('${st.current}/${st.total}'),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.downloadsLibrary,
                      ),
                      icon: const Icon(Icons.folder_open),
                      label: const Text('فتح المكتبة'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: st.status == DownloadStatus.running
                          ? ref.read(downloadControllerProvider.notifier).cancel
                          : null,
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء'),
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
