import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// أقسام الصفحة
import 'widgets/index.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('الإعدادات'),
          automaticallyImplyLeading: true,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward
                        : Icons.arrow_back,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
        ),
        body: ListView(
          children: [
            AppearanceSection(),
            GoalsSection(),
            NotificationsSection(),
            UsageSection(),
            AyahOfDaySection(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
