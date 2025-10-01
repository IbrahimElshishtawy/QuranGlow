import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
        body: ListView(
          children: [
            SwitchListTile(
              title: const Text('الوضع الداكن'),
              value: dark,
              onChanged: (_) {},
            ),
            ListTile(
              title: const Text('حجم الخط'),
              subtitle: const Text('افتراضي'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {},
            ),
            ListTile(
              title: const Text('اختيار القارئ'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
