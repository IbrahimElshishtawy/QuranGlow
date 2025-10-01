import 'package:flutter/material.dart';

class TafsirExplorerPage extends StatelessWidget {
  const TafsirExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tafasir = List.generate(10, (i) => 'تفسير رقم ${i + 1}');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التفسير'), centerTitle: true),
        body: ListView.separated(
          itemCount: tafasir.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            title: Text(tafasir[i]),
            subtitle: const Text('وصف مختصر للتفسير...'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
