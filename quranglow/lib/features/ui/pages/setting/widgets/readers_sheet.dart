// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';

class ReadersSheet extends ConsumerWidget {
  const ReadersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editions = ref.watch(audioEditionsProvider);
    return SafeArea(
      child: editions.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            Padding(padding: const EdgeInsets.all(24), child: Text('خطأ: $e')),
        data: (list) {
          return ListView.separated(
            shrinkWrap: true,
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = list[i] as Map<String, dynamic>;
              final id = (m['identifier'] ?? m['id'] ?? '').toString();
              final name = (m['name'] ?? m['englishName'] ?? id).toString();
              return ListTile(
                title: Text(name),
                subtitle: Text(id),
                onTap: () => Navigator.pop(context, id),
              );
            },
          );
        },
      ),
    );
  }
}
