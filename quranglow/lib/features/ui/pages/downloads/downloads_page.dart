// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = List.generate(4, (i) => ('ملف صوتي #${i + 1}', i * 0.2));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التنزيلات'), centerTitle: true),
        body: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final (title, p) = items[i];
            return ListTile(
              title: Text(title),
              subtitle: LinearProgressIndicator(value: p.toDouble()),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
