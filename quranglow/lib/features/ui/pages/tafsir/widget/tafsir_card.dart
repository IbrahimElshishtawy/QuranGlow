import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'error_card.dart';

class TafsirCard extends StatelessWidget {
  const TafsirCard({
    super.key,
    required this.tafsir,
    required this.editionName,
  });

  final AsyncValue<String> tafsir;
  final String? editionName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return tafsir.when(
      loading: () => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (e, _) => ErrorCard(msg: 'خطأ في جلب التفسير: $e'),
      data: (text) => Card(
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      editionName?.isNotEmpty == true
                          ? editionName!
                          : 'التفسير',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'نسخ',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                    },
                    icon: const Icon(Icons.copy_outlined, size: 20),
                  ),
                  IconButton(
                    tooltip: 'مشاركة',
                    onPressed: () => Share.share(text),
                    icon: const Icon(Icons.share_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                text.isEmpty ? 'لا يوجد نص.' : text,
                textAlign: TextAlign.justify,
                style: const TextStyle(height: 1.9, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
