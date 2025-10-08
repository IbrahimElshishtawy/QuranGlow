// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:test/core/data/surah_names_ar.dart';
import 'package:test/features/ui/pages/mushaf/mushaf_page.dart';

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
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(.15),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              kSurahNamesAr[i],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MushafPage(chapter: i + 1)),
              );
            },
          ),
        ),
      ),
    );
  }
}
