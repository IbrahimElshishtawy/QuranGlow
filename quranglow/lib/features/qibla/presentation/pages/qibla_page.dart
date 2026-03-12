import 'package:flutter/material.dart';
import 'package:quranglow/features/qibla/presentation/widgets/qibla_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  Key _compassKey = UniqueKey();

  void _refreshCompass() {
    setState(() => _compassKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('اتجاه القبلة'),
          actions: [
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
                child: QiblaCompass(key: _compassKey),
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
