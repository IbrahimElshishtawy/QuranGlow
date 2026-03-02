// lib/features/ui/pages/azkar/widgets/tasbih_counter.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';

import 'dhikr_quick_list.dart';


class TasbihCounter extends ConsumerStatefulWidget {
  const TasbihCounter({super.key});

  @override
  ConsumerState<TasbihCounter> createState() => _TasbihCounterState();
}

class _TasbihCounterState extends ConsumerState<TasbihCounter> {
  int _count = 0;
  int _target = 33;
  int _rounds = 0;
  bool _vibrate = true;
  bool _sound = false;

  void _inc() {
    setState(() {
      _count++;
      if (_count >= _target) {
        _rounds++;
        _count = 0;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('أُنجزت دورة $_rounds')));
      }
      _syncTasbih();
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
      _rounds = 0;
      _syncTasbih();
    });
  }

  void _syncTasbih() {
    ref.read(firebaseSyncServiceProvider).syncTasbih({
      'count': _count,
      'target': _target,
      'rounds': _rounds,
      'vibrate': _vibrate,
      'sound': _sound,
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('الإعدادات', style: t.titleMedium),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('اهتزاز عند التسبيح'),
                value: _vibrate,
                onChanged: (v) => setState(() => _vibrate = v),
              ),
              SwitchListTile(
                title: const Text('صوت عند التسبيح'),
                value: _sound,
                onChanged: (v) => setState(() => _sound = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('الهدف', style: t.titleMedium),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('الهدف لكل دورة'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _target,
                items: const [33, 99, 100]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (v) => setState(() => _target = v ?? 33),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('العدّاد', style: t.titleMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Text('$_count / $_target', style: t.displaySmall),
                const SizedBox(height: 8),
                Text('الدورات المكتملة: $_rounds'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.touch_app),
                  label: const Text('سَبِّح'),
                  onPressed: _inc,
                  style: FilledButton.styleFrom(minimumSize: const Size(200, 56)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة ضبط'),
                  onPressed: _reset,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('أذكار سريعة', style: t.titleMedium),
        const DhikrQuickList(onTapAny: null),
      ],
    );
  }
}
