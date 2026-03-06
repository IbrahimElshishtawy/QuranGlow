// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:quranglow/core/data/surah_names_ar.dart';
import 'package:quranglow/features/mushaf/presentation/pages/mushaf_page.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة السور'), centerTitle: true),
        body: ListView.separated(
          itemCount: kSurahNamesAr.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final surahNumber = i + 1; // 1-based
            return ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(.15),
                child: Text(
                  '$surahNumber',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                kSurahNamesAr[i],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MushafPage(chapter: surahNumber),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
