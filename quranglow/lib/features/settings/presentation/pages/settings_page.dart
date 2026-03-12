import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/settings/presentation/widgets/goals_section.dart';
import 'package:quranglow/features/settings/presentation/widgets/notifications_section.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

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
          automaticallyImplyLeading: false,
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
          padding: EdgeInsets.all(12),
          children: [
            GoalsSection(),
            SizedBox(height: 12),
            NotificationsSection(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
