import 'package:flutter/material.dart';
import 'section_header.dart';

class AyahOfDaySection extends StatelessWidget {
  const AyahOfDaySection({super.key});

  @override
  Widget build(BuildContext context) {
    void toast(String msg) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg)));

    return Column(
      children: [
        const SectionHeader('آية اليوم'),
        ListTile(
          leading: const Icon(Icons.auto_stories),
          title: const Text('تحديث آية اليوم'),
          subtitle: const Text('تحديث يدوي الآن'),
          onTap: () => toast('تم تحديث آية اليوم!'),
        ),
      ],
    );
  }
}
