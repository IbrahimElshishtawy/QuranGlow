import 'package:flutter/material.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(5, (i) => 'إشارة مرجعية #${i + 1}');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المحفوظات'), centerTitle: true),
        body: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(items[i]),
            subtitle: const Text('سورة • آية'),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
