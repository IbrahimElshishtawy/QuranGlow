import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      ('مرحبًا بك', 'تطبيق لقراءة القرآن بتجربة سلسة.'),
      ('التلاوة', 'استمع لتلاوات متعددة.'),
      ('الأهداف', 'خطط لختمتك وتابع تقدّمك.'),
    ];
    int index = 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                pages[index].$1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(pages[index].$2, textAlign: TextAlign.center),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () {}, child: const Text('تخطي')),
                  FilledButton(onPressed: () {}, child: const Text('التالي')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
