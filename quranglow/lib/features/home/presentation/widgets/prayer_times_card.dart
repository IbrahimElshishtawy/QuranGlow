import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/adhan_sound.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/features/home/presentation/providers/prayer_times_provider.dart';
import 'package:quranglow/features/home/presentation/widgets/home_surface_card.dart';
import 'package:quranglow/features/home/presentation/widgets/section_title.dart';

class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  late final Timer _ticker;

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
    final settings = ref.watch(settingsProvider).valueOrNull;
    final selectedAdhan = settings?.adhanSound ?? AdhanSounds.makkah;

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
                Text('تعذر تحميل المواقيت: $e'),
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
            const ordered = [
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            await NotificationService.instance
                                .requestPermissionsIfNeededFromUI(context);
                            final days = await ref
                                .read(prayerTimesServiceProvider)
                                .fetchUpcomingDays();
                            await ref
                                .read(settingsProvider.notifier)
                                .setPrayerNotificationsEnabled(true);
                            await NotificationService.instance
                                .schedulePrayerNotifications(days: days);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم تفعيل إشعارات الأذان بصوت ${selectedAdhan.label}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active_rounded),
                          label: const Text('تفعيل إشعارات الأذان'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await NotificationService.instance
                              .cancelPrayerNotifications();
                          await ref
                              .read(settingsProvider.notifier)
                              .setPrayerNotificationsEnabled(false);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إيقاف تنبيهات الصلاة المجدولة'),
                            ),
                          );
                        },
                        child: const Text('إيقاف'),
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
                            value: selectedAdhan.id,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (value) async {
                              if (value == null) return;
                              await ref
                                  .read(settingsProvider.notifier)
                                  .setAdhanSoundId(value);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم اختيار ${AdhanSounds.byId(value).label} لصوت الأذان',
                                  ),
                                ),
                              );
                            },
                            items: AdhanSounds.values
                                .map(
                                  (sound) => DropdownMenuItem<String>(
                                    value: sound.id,
                                    child: Text(
                                      sound.label,
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
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الصوت المختار سيُستخدم عند إشعار الأذان القادم',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
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
                          childAspectRatio: 1.75,
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
