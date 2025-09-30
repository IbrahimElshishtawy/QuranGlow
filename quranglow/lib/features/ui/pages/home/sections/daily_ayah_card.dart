import 'package:flutter/material.dart';

class DailyAyahCard extends StatelessWidget {
  const DailyAyahCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'آية اليوم',
          actionText: 'المزيد',
          onAction: () {
            Navigator.pushNamed(context, AppRoutes.ayah);
          },
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary.withOpacity(.10), cs.surfaceContainerHighest],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(.20)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ﴾',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Opacity(
                opacity: .75,
                child: Text('البقرة • 255', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
