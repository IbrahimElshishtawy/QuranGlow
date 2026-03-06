import 'package:flutter/material.dart';

class AyahCard extends StatelessWidget {
  const AyahCard({
    super.key,
    required this.surahName,
    required this.ayah,
    required this.ayahText,
  });

  final String surahName;
  final int ayah;
  final String ayahText;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$surahName • آية $ayah',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              ayahText.isEmpty ? '—' : ayahText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                height: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
