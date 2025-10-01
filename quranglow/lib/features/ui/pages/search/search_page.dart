import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _c = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final results = List.generate(6, (i) => 'نتيجة بحث #${i + 1}');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('بحث'), centerTitle: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _c,
                decoration: InputDecoration(
                  hintText: 'ابحث في الآيات والسور...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => setState(() {}),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  title: Text(results[i]),
                  subtitle: const Text('نص مقتطع من النتيجة...'),
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
