import 'package:flutter/material.dart';
import 'package:quranglow/core/widgets/pro_app_bar.dart';
import 'package:quranglow/features/qibla/presentation/widgets/qibla_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  Key _compassKey = UniqueKey();
  bool _showEffects = true;
  bool _showCalibrationCard = true;
  bool _showHintCard = true;
  bool _showInfoCards = true;

  void _refreshCompass() {
    setState(() => _compassKey = UniqueKey());
  }

  Future<void> _openOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setSheet) {
            void update(void Function() fn) {
              setState(fn);
              setSheet(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'خيارات البوصلة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خصص مظهر البوصلة بالشكل الذي يناسبك.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: _showEffects,
                      onChanged: (v) => update(() => _showEffects = v),
                      title: const Text('تفعيل التأثيرات البصرية'),
                    ),
                    SwitchListTile.adaptive(
                      value: _showInfoCards,
                      onChanged: (v) => update(() => _showInfoCards = v),
                      title: const Text('إظهار بطاقات معلومات الاتجاه'),
                    ),
                    SwitchListTile.adaptive(
                      value: _showCalibrationCard,
                      onChanged: (v) => update(() => _showCalibrationCard = v),
                      title: const Text('إظهار بطاقة المعايرة'),
                    ),
                    SwitchListTile.adaptive(
                      value: _showHintCard,
                      onChanged: (v) => update(() => _showHintCard = v),
                      title: const Text('إظهار بطاقة الإرشادات'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              update(() {
                                _showEffects = true;
                                _showCalibrationCard = true;
                                _showHintCard = true;
                                _showInfoCards = true;
                              });
                            },
                            icon: const Icon(Icons.settings_backup_restore_rounded),
                            label: const Text('الوضع الافتراضي'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _refreshCompass,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('إعادة الضبط'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: ProAppBar(
          title: 'اتجاه القبلة',
          subtitle: 'بوصلة دقيقة مع خيارات العرض والمعايرة',
          actions: [
            IconButton(
              tooltip: 'خيارات',
              icon: const Icon(Icons.tune_rounded),
              onPressed: _openOptions,
            ),
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refreshCompass,
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cs.surface, cs.surfaceContainerLowest],
                  ),
                ),
              ),
            ),
            _GlowOrb(
              alignment: Alignment.topRight,
              offset: const Offset(120, -120),
              size: 260,
              color: cs.primary.withValues(alpha: 0.13),
            ),
            _GlowOrb(
              alignment: Alignment.bottomLeft,
              offset: const Offset(-120, 140),
              size: 240,
              color: cs.tertiary.withValues(alpha: 0.10),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: QiblaCompass(
                  key: _compassKey,
                  showEffects: _showEffects,
                  showCalibrationCard: _showCalibrationCard,
                  showHintCard: _showHintCard,
                  showInfoCards: _showInfoCards,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.offset,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final Offset offset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: offset,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0)],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
