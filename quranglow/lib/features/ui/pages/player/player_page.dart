// lib/features/ui/pages/player/player_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/transport_controls.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final editions = ref.watch(audioEditionsProvider);
    final ed = ref.watch(editionIdProvider);
    final chapter = ref.watch(chapterProvider);
    final ctrl = ref.watch(playerControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('المشغّل'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: cs.onSurface,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary.withOpacity(.12),
                    cs.surfaceContainerHighest.withOpacity(.25),
                    cs.surface,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final kb = MediaQuery.of(context).viewInsets.bottom;
                  return ListView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + kb),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: editions.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text('خطأ بالإصدارات: $e'),
                              data: (list) {
                                final items = list
                                    .whereType<Map>()
                                    .map((m) => Map<String, dynamic>.from(m))
                                    .toList();
                                if (items.isEmpty) {
                                  return const Text(
                                    'لا توجد إصدارات صوتية متاحة',
                                  );
                                }
                                return DropdownButtonFormField<String>(
                                  value: ed,
                                  decoration: const InputDecoration(
                                    labelText: 'اختيار القارئ',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  isExpanded: true,
                                  items: items.map((m) {
                                    final id = (m['identifier'] ?? '')
                                        .toString();
                                    final name =
                                        (m['name'] ?? m['englishName'] ?? id)
                                            .toString();
                                    return DropdownMenuItem(
                                      value: id,
                                      child: Text(name),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      ref
                                          .read(
                                            playerControllerProvider.notifier,
                                          )
                                          .changeEdition(v);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              initialValue: chapter.toString(),
                              decoration: const InputDecoration(
                                labelText: 'السورة',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (v) {
                                final n = int.tryParse(v) ?? chapter;
                                ref
                                    .read(playerControllerProvider.notifier)
                                    .changeChapter(n);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh.withOpacity(.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cs.outlineVariant.withOpacity(.4),
                              ),
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [cs.primary, cs.secondary],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'سورة $chapter',
                                        style: t.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text('القارئ: $ed', style: t.bodyMedium),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _Pill(text: 'تشغيل متصل'),
                                          const SizedBox(width: 8),
                                          _Pill(text: 'جودة عادية'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.10),
                      Center(
                        child: ctrl.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تعذر التحميل'),
                              const SizedBox(height: 8),
                              Text(
                                '$e',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          data: (s) => TransportControls(state: s),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
