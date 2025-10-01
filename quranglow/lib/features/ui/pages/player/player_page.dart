import 'package:flutter/material.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المشغّل'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const ListTile(
                  title: Text('سورة البقرة'),
                  subtitle: Text('القارئ: مشاري العفاسي'),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  IconButton(
                    icon: Icon(Icons.skip_previous, size: 32),
                    onPressed: null,
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.play_circle, size: 48),
                    onPressed: null,
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 32),
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const LinearProgressIndicator(value: .3),
            ],
          ),
        ),
      ),
    );
  }
}
