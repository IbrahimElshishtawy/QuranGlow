// lib/features/ui/pages/downloads/surah_files_page.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SurahFilesPage extends StatefulWidget {
  final String reciterId;
  final int surah;
  const SurahFilesPage({
    super.key,
    required this.reciterId,
    required this.surah,
  });

  @override
  State<SurahFilesPage> createState() => _SurahFilesPageState();
}

class _SurahFilesPageState extends State<SurahFilesPage> {
  late final AudioPlayer _player;
  bool _loading = true;
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _scan();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(
      p.join(
        docs.path,
        'QuranGlow',
        'downloads',
        widget.reciterId,
        '${widget.surah}',
      ),
    );
  }

  Future<void> _scan() async {
    setState(() => _loading = true);
    final d = await _dir();
    final list = <File>[];
    if (await d.exists()) {
      list.addAll(
        d
            .listSync()
            .whereType<File>()
            .where((f) => f.path.toLowerCase().endsWith('.mp3'))
            .toList(),
      );
      // فرز رقمي بالأسماء 001.mp3 -> 999.mp3
      list.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    }
    if (!mounted) return;
    setState(() {
      _files = list;
      _loading = false;
    });
  }

  Future<void> _play(int i) async {
    await _player.stop();
    await _player.setAudioSource(
      ConcatenatingAudioSource(
        children: _files.map((f) => AudioSource.uri(Uri.file(f.path))).toList(),
      ),
      initialIndex: i,
    );
    await _player.play();
  }

  Future<void> _deleteAll() async {
    final d = await _dir();
    if (await d.exists()) {
      await d.delete(recursive: true);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ملفات السورة ${widget.surah} • ${widget.reciterId}'),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _scan),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف كل ملفات السورة؟'),
                    content: const Text('لا يمكن التراجع عن هذه العملية.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
                if (ok == true) _deleteAll();
              },
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _files.isEmpty
            ? Center(
                child: Text(
                  'لا توجد ملفات',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _files.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = _files[i];
                  final name = p.basenameWithoutExtension(f.path); // 001
                  return Card(
                    elevation: 0,
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primary.withOpacity(.12),
                        child: Text(
                          '${int.tryParse(name) ?? i + 1}',
                          style: TextStyle(color: cs.primary),
                        ),
                      ),
                      title: Text('آية ${int.tryParse(name) ?? i + 1}'),
                      subtitle: Text(
                        f.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _play(i),
                      ),
                      onTap: () => _play(i),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
