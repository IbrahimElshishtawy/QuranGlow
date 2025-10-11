// lib/features/ui/pages/azkar/widgets/reminder_editor.dart
// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../core/model/reminder/reminder.dart';


class ReminderEditor extends StatefulWidget {
  const ReminderEditor({super.key, this.existing});
  final Reminder? existing;

  @override
  State<ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends State<ReminderEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title =
  TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _notes =
  TextEditingController(text: widget.existing?.notes ?? '');
  DateTime? _date;
  TimeOfDay? _time;
  bool _daily = false;

  @override
  void initState() {
    super.initState();
    final dt = widget.existing?.dateTime;
    if (dt != null) {
      _date = DateTime(dt.year, dt.month, dt.day);
      _time = TimeOfDay.fromDateTime(dt);
      _daily = widget.existing!.daily;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final now = DateTime.now();
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existing == null ? 'تذكير جديد' : 'تعديل التذكير',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_date == null
                            ? 'التاريخ'
                            : '${_date!.day}/${_date!.month}/${_date!.year}'),
                        onPressed: () async {
                          try {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: now,
                              initialDate: _date ?? now,
                              lastDate: now.add(const Duration(days: 365 * 3)),
                              locale: const Locale('ar'),
                            );
                            if (picked != null) setState(() => _date = picked);
                          } catch (_) {}
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: Text(_time == null
                            ? 'الوقت'
                            : _time!.format(context)),
                        onPressed: () async {
                          try {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime:
                              _time ?? TimeOfDay.fromDateTime(now),
                            );
                            if (picked != null) setState(() => _time = picked);
                          } catch (_) {}
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _daily,
                  onChanged: (v) => setState(() => _daily = v),
                  title: const Text('تكرار يومي'),
                  secondary: const Icon(Icons.autorenew),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final date = _date, time = _time;
    if (date == null || time == null) {
      _err('حدّد التاريخ والوقت');
      return;
    }
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (dt.isBefore(DateTime.now()) && !_daily) {
      _err('الوقت المختار قد مضى. فعّل التكرار اليومي أو اختر وقتًا لاحقًا.');
      return;
    }
    final item = Reminder(
      id: 100000 + Random().nextInt(900000),
      title: _title.text.trim(),
      dateTime: dt,
      daily: _daily,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    Navigator.of(context).pop(item);
  }

  void _err(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }
}
