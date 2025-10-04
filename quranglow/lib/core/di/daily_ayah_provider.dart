import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyAyah {
  final String text;
  final String ref; // مثال: "البقرة • 255"
  const DailyAyah({required this.text, required this.ref});
}

final dailyAyahProvider = FutureProvider<DailyAyah>((ref) async {
  final day = DateTime.now().toUtc().difference(DateTime(2024, 1, 1)).inDays;

  const samples = <DailyAyah>[
    DailyAyah(
      text: '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ﴾',
      ref: 'البقرة • 255',
    ),
    DailyAyah(
      text: '﴿إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ﴾',
      ref: 'الفاتحة • 5',
    ),
    DailyAyah(text: '﴿فَاذْكُرُونِي أَذْكُرْكُمْ﴾', ref: 'البقرة • 152'),
    DailyAyah(text: '﴿وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ﴾', ref: 'الحديد • 4'),
    DailyAyah(text: '﴿وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ﴾', ref: 'هود • 88'),
    DailyAyah(text: '﴿إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾', ref: 'الشرح • 6'),
    DailyAyah(
      text: '﴿وَعَسَىٰ أَنْ تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَكُمْ﴾',
      ref: 'البقرة • 216',
    ),
    DailyAyah(
      text: '﴿لَا تَقْنَطُوا مِنْ رَحْمَةِ اللَّهِ﴾',
      ref: 'الزمر • 53',
    ),
  ];

  return samples[day % samples.length];
});
