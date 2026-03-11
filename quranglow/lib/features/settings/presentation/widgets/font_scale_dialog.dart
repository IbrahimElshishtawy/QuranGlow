import 'package:flutter/material.dart';

class FontScaleDialog extends StatefulWidget {
  const FontScaleDialog({super.key, required this.value});
  final double value;

  @override
  State<FontScaleDialog> createState() => _FontScaleDialogState();
}

class _FontScaleDialogState extends State<FontScaleDialog> {
  late double v = widget.value;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حجم الخط'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: v,
              min: 0.8,
              max: 1.4,
              divisions: 12,
              label: v.toStringAsFixed(2),
              onChanged: (x) => setState(() => v = x),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, v),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
