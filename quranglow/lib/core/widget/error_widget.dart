import 'package:flutter/material.dart';

class ErrorWidgetSimple extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidgetSimple({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ],
    ),
  );
}
