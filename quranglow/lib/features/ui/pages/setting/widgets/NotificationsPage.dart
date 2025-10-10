import 'package:flutter/material.dart';

import 'notifications_section.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: const SingleChildScrollView(child: NotificationsSection()),
    );
  }
}
