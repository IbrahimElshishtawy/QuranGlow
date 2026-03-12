// lib/features/ui/pages/downloads/downloads_library_page.dart

// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quranglow/core/widgets/pro_app_bar.dart';

class DownloadsLibraryPage extends ConsumerStatefulWidget {
  final bool embedded;
  const DownloadsLibraryPage({super.key, this.embedded = false});

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
    _player.dispose();
    super.dispose();
  }

  Future<Directory> _rootDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'QuranGlow', 'downloads', 'audio'));
  }

  Future<Directory> _textRootDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'QuranGlow', 'downloads', 'text'));
  }

  Future<void> _scan() async {
    setState(() => _loading = true);
    final root = await _rootDir();
    final groups = <_SurahGroup>[];
    if (await root.exists()) {
      for (final reciter in root.listSync().whereType<Directory>()) {
        final reciterId = p.basename(reciter.path);
        for (final sdir in reciter.listSync().whereType<Directory>()) {
          final sNum = int.tryParse(p.basename(sdir.path)) ?? 0;
          if (sNum == 0) continue;
          final files =
              sdir
                  .listSync()
                  .whereType<File>()
                  .where((f) => f.path.toLowerCase().endsWith('.mp3'))
                  .toList()
                ..sort((a, b) => a.path.compareTo(b.path));
          if (files.isNotEmpty) {
            final bytes = files.fold<int>(0, (s, f) => s + f.lengthSync());
            groups.add(
              _SurahGroup(
                reciterId: reciterId,
                surah: sNum,
                files: files,
                totalBytes: bytes,
              ),
            );
          }
        }
      }
      groups.sort(
        (a, b) => a.reciterId == b.reciterId
            ? a.surah.compareTo(b.surah)
            : a.reciterId.compareTo(b.reciterId),
      );
    }
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  Future<void> _play(_SurahGroup g, int i) async {
    await _player.stop();
    await _player.setAudioSource(
      ConcatenatingAudioSource(
        children: g.files
            .map((f) => AudioSource.uri(Uri.file(f.path)))
            .toList(),
      ),
      initialIndex: i,
    );
    await _player.play();
  }

  Future<void> _delete(_SurahGroup g) async {
    try {
      await g.files.first.parent.delete(recursive: true);
      await _scan();
    } catch (_) {}
  }

  Future<void> _viewText(int surah) async {
    final root = await _textRootDir();
    final sdir = Directory(p.join(root.path, surah.toString()));
    if (!await sdir.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم تنزيل نص هذه السورة')),
        );
      }
      return;
    }

    final files = sdir.listSync().whereType<File>().toList();
    if (files.isEmpty) return;

    final content = await files.first.readAsString();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Text('نص السورة $surah', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              Text(content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _groups.isEmpty
        ? Center(
            child: Text(
              'لا توجد تنزيلات محفوظة',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _groups.length,
            itemBuilder: (_, i) {
              final g = _groups[i];
              return Card(
                child: ExpansionTile(
                  title: Text(
                    'القارئ: ${g.reciterId} — السورة: ${g.surah}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${g.files.length} ملف • ${_fmt(g.totalBytes)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.description),
                        tooltip: 'عرض النص',
                        onPressed: () => _viewText(g.surah),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(g),
                      ),
                    ],
                  ),
                  children: List.generate(g.files.length, (idx) {
                    final f = g.files[idx];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.audiotrack),
                      title: Text('آية ${p.basenameWithoutExtension(f.path)}'),
                      onTap: () => _play(g, idx),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _play(g, idx),
                      ),
                    );
                  }),
                ),
              );
            },
          );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: ProAppBar(
          title: 'المكتبة الصوتية',
          subtitle: 'شغّل السور والآيات التي تم تنزيلها محليًا',
          actions: [
            IconButton(onPressed: _scan, icon: const Icon(Icons.refresh)),
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
