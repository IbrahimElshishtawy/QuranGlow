import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

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
          automaticallyImplyLeading: false, // عشان نتحكّم إحنا في الـ leading
          leading: IconButton(
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward
                  : Icons.arrow_back,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).maybePop();
              } else {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
          ),
        ),
        body: ListView(
          children: [
            AppearanceSection(),
            GoalsSection(),
            NotificationsSection(),
            AyahOfDaySection(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
