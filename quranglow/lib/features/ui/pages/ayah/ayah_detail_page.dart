import 'package:flutter/material.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';

class AyahDetailPage extends StatelessWidget {
  const AyahDetailPage({
    super.key,
    required this.aya,
    required this.surah,
    this.tafsir,
  });

  final Aya aya;
  final Surah surah;
  final String? tafsir;

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
              Text(
                '﴿${aya.text}﴾',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22, height: 1.8),
              ),
              const SizedBox(height: 12),
              Text(
                '${surah.name} • آية ${aya.numberInSurah}',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              const Text(
                'تفسير مختصر:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    tafsir?.trim().isNotEmpty == true
                        ? tafsir!
                        : 'لا يوجد تفسير متاح.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
