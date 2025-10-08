// lib/features/ui/pages/downloads/downloads_library_page.dart
// ignore_for_file: deprecated_member_use, depend_on_referenced_packages, unintended_html_in_doc_comment

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadsLibraryPage extends ConsumerStatefulWidget {
  final bool embedded;
  const DownloadsLibraryPage({super.key, this.embedded = true});

  @override
  ConsumerState<DownloadsLibraryPage> createState() =>
      _DownloadsLibraryPageState();
}

class _DownloadsLibraryPageState extends ConsumerState<DownloadsLibraryPage> {
  late final AudioPlayer _player;
  bool _loading = true;
  List<_SurahGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _scan();
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<Directory> _rootDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'QuranGlow', 'downloads'));
  }

  Future<void> _scan() async {
    try {
      final root = await _rootDir();
      if (!await root.exists()) {
        setState(() {
          _groups = [];
          _loading = false;
        });
        return;
      }

      final groups = <_SurahGroup>[];

      for (final reciterDir in root.listSync().whereType<Directory>()) {
        final reciterId = p.basename(reciterDir.path);
        for (final surahDir in reciterDir.listSync().whereType<Directory>()) {
          final surahStr = p.basename(surahDir.path);
          final surah = int.tryParse(surahStr) ?? 0;
          if (surah <= 0) continue;

          final files =
              surahDir
                  .listSync()
                  .whereType<File>()
                  .where((f) => f.path.toLowerCase().endsWith('.mp3'))
                  .toList()
                ..sort((a, b) => a.path.compareTo(b.path));

          if (files.isEmpty) continue;

          final totalBytes = files.fold<int>(
            0,
            (sum, f) => sum + (f.lengthSync()),
          );

          groups.add(
            _SurahGroup(
              reciterId: reciterId,
              surah: surah,
              files: files,
              totalBytes: totalBytes,
            ),
          );
        }
      }

      groups.sort((a, b) {
        final c = a.reciterId.compareTo(b.reciterId);
        return c != 0 ? c : a.surah.compareTo(b.surah);
      });

      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _groups = [];
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر قراءة مجلد التنزيلات')),
        );
      }
    }
  }

  String _shortReciterName(String id) {
    if (id.contains('.')) return id.split('.').last;
    if (id.length <= 12) return id;
    return '${id.substring(0, 12)}…';
  }

  Future<void> _playGroupFromIndex(_SurahGroup g, int startIndex) async {
    try {
      await _player.stop();

      final sources = g.files
          .map((f) => AudioSource.uri(Uri.file(f.path)))
          .toList();

      final playlist = ConcatenatingAudioSource(children: sources);

      await _player.setAudioSource(playlist, initialIndex: startIndex);
      await _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذّر تشغيل الملفات')));
    }
  }

  Future<void> _deleteGroup(_SurahGroup g) async {
    try {
      final d = g.files.first.parent;
      if (await d.exists()) {
        await d.delete(recursive: true);
      }
      await _scan();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذّر الحذف')));
    }
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_groups.isEmpty) {
      body = Center(
        child: Text(
          'لا توجد تنزيلات محفوظة',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _groups.length,
        itemBuilder: (_, i) {
          final g = _groups[i];
          return Card(
            child: ExpansionTile(
              title: Text(
                'القارئ: ${_shortReciterName(g.reciterId)} — السورة: ${g.surah}',
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${g.files.length} ملف • ${_fmtSize(g.totalBytes)}',
              ),
              trailing: IconButton(
                tooltip: 'حذف السورة',
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteGroup(g),
              ),
              children: List.generate(g.files.length, (idx) {
                final f = g.files[idx];
                final name = p.basenameWithoutExtension(f.path);
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.audiotrack),
                  title: Text('آية $name'),
                  subtitle: Text(_shortReciterName(p.basename(f.parent.path))),
                  onTap: () => _playGroupFromIndex(g, idx),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _playGroupFromIndex(g, idx),
                  ),
                );
              }),
            ),
          );
        },
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: widget.embedded
            ? null
            : AppBar(
                title: const Text('التنزيلات المحفوظة'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    tooltip: 'تحديث',
                    icon: const Icon(Icons.refresh),
                    onPressed: _scan,
                  ),
                ],
              ),
        body: body,
      ),
    );
  }
}

class _SurahGroup {
  final String reciterId;
  final int surah;
  final List<File> files;
  final int totalBytes;

  _SurahGroup({
    required this.reciterId,
    required this.surah,
    required this.files,
    required this.totalBytes,
  });
}
