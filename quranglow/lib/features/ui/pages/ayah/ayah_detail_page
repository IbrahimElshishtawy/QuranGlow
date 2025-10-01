import 'package:flutter/material.dart';

class AyahDetailPage extends StatelessWidget {
  const AyahDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الآية'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('﴿نص الآية هنا﴾', textAlign: TextAlign.right, style: const TextStyle(fontSize: 22, height: 1.8)),
              const SizedBox(height: 12),
              Text('سورة البقرة • آية 255', style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              const Text('تفسير مختصر:', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Expanded(child: SingleChildScrollView(child: Text('نص تفسير/شرح...'))),
            ],
          ),
        ),
      ),
    );
  }
}
