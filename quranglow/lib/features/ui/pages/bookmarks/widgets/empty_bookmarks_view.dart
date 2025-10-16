// TODO Implement this library.
import 'package:flutter/material.dart';

class EmptyBookmarksView extends StatelessWidget {
  const EmptyBookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        'لا توجد إشارات مرجعية بعد',
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}
