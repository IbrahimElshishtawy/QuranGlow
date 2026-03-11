import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/home/presentation/providers/prayer_times_provider.dart';
import 'package:quranglow/features/home/presentation/widgets/home_surface_card.dart';
import 'package:quranglow/features/home/presentation/widgets/section_title.dart';

class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  static const _muezzins = <String>[
    'مشاري العفاسي',
    'ناصر القطامي',
    'علي الملا',
  ];

  late final Timer _ticker;
  String _selectedMuezzin = _muezzins.first;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prayerState = ref.watch(prayerTimesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'مواقيت الصلاة',
          actionText: 'تحديث',
          onAction: () => ref.refresh(prayerTimesProvider),
        ),
        const SizedBox(height: 8),
        prayerState.when(
          loading: () => const HomeSurfaceCard(
            emphasis: true,
            child: SizedBox(
              height: 128,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => HomeSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تعذّر تحميل المواقيت: $e'),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => ref.refresh(prayerTimesProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (data) {
            final remaining = _formatRemaining(data.nextPrayerTime);
            final ordered = const [
              'Fajr',
              'Sunrise',
              'Dhuhr',
              'Asr',
              'Maghrib',
              'Isha',
            ];

            return HomeSurfaceCard(
              emphasis: true,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الصلاة القادمة: ${_arabicPrayerName(data.nextPrayerName)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        remaining,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'طريقة الحساب: ${data.methodName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedMuezzin,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedMuezzin = v);
                            },
                            items: _muezzins
                                .map(
                                  (m) => DropdownMenuItem<String>(
                                    value: m,
                                    child: Text(
                                      m,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: ordered.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.25,
                        ),
                    itemBuilder: (_, i) {
                      final key = ordered[i];
                      final time = data.prayers[key];
                      final isNext = key == data.nextPrayerName;
                      return _PrayerTimeTile(
                        title: _arabicPrayerName(key),
                        time: time == null ? '--:--' : _formatTime(time),
                        highlight: isNext,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatRemaining(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return 'الآن';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    final s = diff.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _arabicPrayerName(String key) {
    switch (key) {
      case 'Fajr':
        return 'الفجر';
      case 'Sunrise':
        return 'الشروق';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return key;
    }
  }
}

class _PrayerTimeTile extends StatelessWidget {
  const _PrayerTimeTile({
    required this.title,
    required this.time,
    required this.highlight,
  });

  final String title;
  final String time;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: highlight ? cs.primary.withValues(alpha: 0.16) : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? cs.primary.withValues(alpha: 0.6)
              : cs.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: highlight ? cs.primary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
