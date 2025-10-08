import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/features/ui/pages/setting/widgets/settings_providers.dart';

import 'section_header.dart';

class UsageSection extends ConsumerWidget {
  const UsageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keepOn = ref.watch(keepScreenOnProvider);
    final cellular = ref.watch(useCellularProvider);
    final haptics = ref.watch(hapticsProvider);
    final reduced = ref.watch(reduceMotionProvider);

    void toast(String msg) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg)));

    return Column(
      children: [
        const SectionHeader('استخدام التطبيق'),
        SwitchListTile(
          title: const Text('إبقاء الشاشة فعّالة أثناء القراءة'),
          subtitle: const Text('مفيد عند القراءة الطويلة'),
          value: keepOn,
          onChanged: (v) {
            ref.read(keepScreenOnProvider.notifier).state = v;
            toast(v ? 'تم تفعيل إبقاء الشاشة' : 'تم إيقاف إبقاء الشاشة');
          },
        ),
        SwitchListTile(
          title: const Text('السماح باستخدام البيانات الخلوية'),
          subtitle: const Text('للتنزيلات/الاستماع عند عدم وجود Wi-Fi'),
          value: cellular,
          onChanged: (v) {
            ref.read(useCellularProvider.notifier).state = v;
            toast(v ? 'سيسمح بالبيانات الخلوية' : 'يُفضَّل Wi-Fi فقط');
          },
        ),
        SwitchListTile(
          title: const Text('الاهتزاز (Haptics)'),
          subtitle: const Text('اهتزاز خفيف لتأكيد الأفعال'),
          value: haptics,
          onChanged: (v) => ref.read(hapticsProvider.notifier).state = v,
        ),
        SwitchListTile(
          title: const Text('تقليل الحركة والأنيميشن'),
          subtitle: const Text('مفيد للأجهزة الضعيفة'),
          value: reduced,
          onChanged: (v) => ref.read(reduceMotionProvider.notifier).state = v,
        ),
      ],
    );
  }
}
