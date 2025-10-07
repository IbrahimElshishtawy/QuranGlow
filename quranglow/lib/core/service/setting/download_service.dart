// lib/core/service/download_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  DownloadService({required this.dio});
  final Dio dio;

  Future<Directory> _rootDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory('${dir.path}/quran_audio');
    if (!await base.exists()) await base.create(recursive: true);
    return base;
  }

  Future<Directory> surahDir({
    required String reciter,
    required int surah,
  }) async {
    final root = await _rootDir();
    final d = Directory('${root.path}/$reciter/$surah');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// تنزيل ملف واحد مع تقدم
  Future<void> downloadOne({
    required String url,
    required String savePath,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    await dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      options: Options(responseType: ResponseType.stream),
      cancelToken: cancelToken,
    );
  }
}
