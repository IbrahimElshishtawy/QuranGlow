// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => ErrorCard(msg: 'خطأ في جلب التفسير: $e'),
      data: (text) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editionName?.isNotEmpty == true ? editionName! : 'التفسير',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                text.isEmpty ? 'لا يوجد نص.' : text,
                textAlign: TextAlign.justify,
                style: const TextStyle(height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
