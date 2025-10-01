import 'package:flutter/material.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(114, (i) => 'سورة رقم ${i + 1}');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة السور'), centerTitle: true),
        body: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            title: Text(items[i]),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
