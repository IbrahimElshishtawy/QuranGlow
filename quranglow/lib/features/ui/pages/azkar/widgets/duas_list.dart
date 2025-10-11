// lib/features/ui/pages/azkar/widgets/duas_list.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../../../core/model/reminder/dua.dart';


class DuasList extends StatelessWidget {
  const DuasList({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final duas = _seedDuas;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final d = duas[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(d.title, style: t.titleMedium),
                const SizedBox(height: 8),
                Text(d.text, textAlign: TextAlign.justify),
                if (d.ref != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('المصدر: ${d.ref}', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                  ),
                ]
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemCount: duas.length,
    );
  }
}

final List<Dua> _seedDuas = [
  Dua(
    title: 'دعاء الاستغفار',
    text: 'اللهم إنك عفو كريم تحب العفو فاعفُ عني.',
    ref: 'سنن الترمذي',
  ),
  Dua(
    title: 'دعاء الهمّ',
    text: 'اللهم إني أعوذ بك من الهم والحَزَن، وأعوذ بك من العجز والكسل...',
    ref: 'صحيح البخاري',
  ),
  Dua(
    title: 'دعاء السفر',
    text: 'سبحان الذي سخر لنا هذا وما كنا له مقرنين وإنا إلى ربنا لمنقلبون.',
    ref: 'صحيح مسلم',
  ),
];
