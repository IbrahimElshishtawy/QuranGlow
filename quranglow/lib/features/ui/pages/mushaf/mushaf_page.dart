import 'package:flutter/material.dart';

class MushafPage extends StatelessWidget {
  const MushafPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المصحف'), centerTitle: true),
        body: const Center(child: Text('عارض صفحات المصحف')),
      ),
    );
  }
}
