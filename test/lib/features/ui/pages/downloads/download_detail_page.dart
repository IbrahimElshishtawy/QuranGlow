// lib/features/ui/pages/downloads/download_detail_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/data/surah_names_ar.dart'; // 👈 استيراد أسماء السور
import 'package:quranglow/features/ui/pages/downloads/controller/download_controller.dart';

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

    ref
        .read(downloadControllerProvider.notifier)
        .downloadSurah(
          surah: widget.surah,
          reciterId: widget.reciterId,
          ayahUrls: urls,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final st = ref.watch(downloadControllerProvider);

    // 👇 اسم السورة بدل الرقم (مع fallback آمن)
    final surahName = (widget.surah >= 1 && widget.surah < kSurahNamesAr.length)
        ? kSurahNamesAr[widget.surah]
        : widget.surah.toString();

    final title = 'سورة $surahName';
    final sub = 'القارئ: ${widget.reciterId}';

    final statusText = switch (st.status) {
      DownloadStatus.running => 'جاري التنزيل...',
      DownloadStatus.done => 'اكتمل التنزيل',
      DownloadStatus.error => 'خطأ: ${st.message ?? ''}',
      DownloadStatus.cancelled => 'تم الإلغاء',
      _ => 'جاهز',
    };

    final onCancel = (st.status == DownloadStatus.running)
        ? ref.read(downloadControllerProvider.notifier).cancel
        : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التنزيل'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(title: Text(title), subtitle: Text(sub)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value:
                    (st.status == DownloadStatus.running ||
                        st.status == DownloadStatus.done)
                    ? st.progress
                    : null,
                backgroundColor: cs.primary.withOpacity(.12),
              ),
              const SizedBox(height: 12),
              Text(statusText, style: TextStyle(color: cs.onSurfaceVariant)),
              if (st.total > 0) ...[
                const SizedBox(height: 6),
                Text('${st.current} / ${st.total}'),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.pause),
                    label: const Text('—'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    label: const Text('إلغاء'),
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
