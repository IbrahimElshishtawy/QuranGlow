import 'package:flutter/material.dart';

class AyahPicker extends StatefulWidget {
  const AyahPicker({
    super.key,
    required this.maxAyat,
    required this.ayah,
    required this.onAyahChange,
  });

  final int maxAyat;
  final int ayah;
  final void Function(int ayah) onAyahChange;

  @override
  State<AyahPicker> createState() => _AyahPickerState();
}

class _AyahPickerState extends State<AyahPicker> {
  late int _localAyah;

  @override
  void initState() {
    super.initState();
    _localAyah = widget.ayah;
  }

  @override
  void didUpdateWidget(covariant AyahPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayah != widget.ayah) _localAyah = widget.ayah;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _localAyah.toDouble(),
            min: 1,
            max: widget.maxAyat.toDouble(),
            divisions: widget.maxAyat - 1,
            label: 'آية $_localAyah من ${widget.maxAyat}',
            onChanged: (x) => setState(() => _localAyah = x.round()),
            onChangeEnd: (x) => widget.onAyahChange(x.round()),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: TextFormField(
            key: ValueKey('ayah_${widget.maxAyat}'),
            initialValue: _localAyah.toString(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'الآية',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onFieldSubmitted: (v) {
              final n = int.tryParse(v) ?? _localAyah;
              final clamped = n.clamp(1, widget.maxAyat);
              setState(() => _localAyah = clamped);
              widget.onAyahChange(clamped);
            },
          ),
        ),
      ],
    );
  }
}
