// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DownloadDetailPage extends StatelessWidget {
  const DownloadDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التنزيل'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ListTile(
                title: Text('سورة الكهف'),
                subtitle: Text('القارئ: المنشاوي'),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: .6,
                backgroundColor: cs.primary.withOpacity(.12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.pause),
                    label: const Text('إيقاف مؤقت'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {},
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
