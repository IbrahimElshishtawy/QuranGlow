import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quranglow/core/di/providers.dart';

enum DownloadStatus { idle, running, paused, done, error, cancelled }

class DownloadState {
  const DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.current = 0,
    this.total = 0,
    this.message,
  });

  final DownloadStatus status;
  final double progress;
  final int current;
  final int total;
  final String? message;

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    int? current,
    int? total,
    String? message,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      current: current ?? this.current,
      total: total ?? this.total,
      message: message ?? this.message,
    );
  }
}

class AyahDownload {
  const AyahDownload({required this.ayah, required this.url});

  final int ayah;
  final String url;
}

class DownloadController extends StateNotifier<DownloadState> {
  DownloadController(this.ref) : super(const DownloadState());

  final Ref ref;
  CancelToken? _token;

  Future<bool> downloadSurah({
    required int surah,
    required String reciterId,
    required List<String> ayahUrls,
  }) async {
    final items = <AyahDownload>[
      for (int i = 0; i < ayahUrls.length; i++)
        AyahDownload(ayah: i + 1, url: ayahUrls[i]),
    ];
    return downloadAyat(surah: surah, reciterId: reciterId, items: items);
  }

  Future<bool> downloadAyat({
    required int surah,
    required String reciterId,
    required List<AyahDownload> items,
  }) async {
    if (items.isEmpty) {
      state = state.copyWith(
        status: DownloadStatus.error,
        message: 'لا توجد روابط صوت متاحة للتنزيل.',
      );
      return false;
    }

    final svc = ref.read(downloadServiceProvider);
    final dir = await svc.surahDir(reciter: reciterId, surah: surah);

    _token?.cancel();
    _token = CancelToken();

    state = state.copyWith(
      status: DownloadStatus.running,
      progress: 0,
      current: 0,
      total: items.length,
      message: null,
    );

    try {
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final fileName = item.ayah.toString().padLeft(3, '0');
        final file = File('${dir.path}/$fileName.mp3');

        if (await file.exists() && await file.length() > 0) {
          state = state.copyWith(
            current: i + 1,
            progress: (i + 1) / items.length,
            message: 'تم استخدام الملفات المحفوظة مسبقًا عند توفرها.',
          );
          continue;
        }

        try {
          await svc.downloadOne(
            url: item.url,
            savePath: file.path,
            cancelToken: _token,
            onProgress: (received, total) {
              final fileProgress = total > 0 ? (received / total) : 0.0;
              final overall = (i + fileProgress) / items.length;
              state = state.copyWith(
                status: DownloadStatus.running,
                current: i,
                progress: overall.clamp(0, 1),
              );
            },
          );
        } catch (_) {
          if (await file.exists()) {
            try {
              await file.delete();
            } catch (_) {}
          }
          rethrow;
        }

        state = state.copyWith(
          current: i + 1,
          progress: (i + 1) / items.length,
        );
      }

      state = state.copyWith(
        status: DownloadStatus.done,
        message: 'اكتمل التنزيل بنجاح.',
      );
      return true;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = state.copyWith(
          status: DownloadStatus.cancelled,
          message: 'تم إلغاء التنزيل.',
        );
      } else {
        state = state.copyWith(
          status: DownloadStatus.error,
          message: e.message ?? 'تعذر تنزيل الملفات بسبب الشبكة.',
        );
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        status: DownloadStatus.error,
        message: 'تعذر إكمال التنزيل: $e',
      );
      return false;
    }
  }

  void cancel() {
    _token?.cancel('user_cancel');
  }
}

Future<File> saveAudioFile(
  String url,
  String reciterId,
  int surah,
  int index,
) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/QuranGlow/downloads/$reciterId/$surah');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final file = File('${dir.path}/${index.toString().padLeft(3, '0')}.mp3');
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    await file.writeAsBytes(response.bodyBytes);
  } else {
    throw Exception('فشل تحميل الآية رقم $index');
  }

  return file;
}

final downloadControllerProvider =
    StateNotifierProvider.autoDispose<DownloadController, DownloadState>(
      (ref) => DownloadController(ref),
    );
