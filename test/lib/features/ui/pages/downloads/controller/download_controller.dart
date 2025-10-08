import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

class DownloadController extends StateNotifier<DownloadState> {
  DownloadController(this.ref) : super(const DownloadState());
  final Ref ref;

  CancelToken? _token;

  Future<void> downloadSurah({
    required int surah,
    required String reciterId, // مثل 'ar.alafasy'
    required List<String> ayahUrls, // روابط صوت الآيات
  }) async {
    if (ayahUrls.isEmpty) {
      state = state.copyWith(
        status: DownloadStatus.error,
        message: 'لا توجد روابط صوت',
      );
      return;
    }

    final svc = ref.read(downloadServiceProvider);
    final dir = await svc.surahDir(reciter: reciterId, surah: surah);

    _token?.cancel();
    _token = CancelToken();

    state = state.copyWith(
      status: DownloadStatus.running,
      progress: 0,
      current: 0,
      total: ayahUrls.length,
      message: null,
    );

    try {
      for (int i = 0; i < ayahUrls.length; i++) {
        final url = ayahUrls[i];
        final file = File('${dir.path}/${i + 1}.mp3');

        await svc.downloadOne(
          url: url,
          savePath: file.path,
          cancelToken: _token,
          onProgress: (r, t) {
            final pFile = (t > 0) ? (r / t) : 0.0;
            final overall = (i + pFile) / ayahUrls.length;
            state = state.copyWith(
              status: DownloadStatus.running,
              current: i,
              progress: overall.clamp(0, 1),
            );
          },
        );

        state = state.copyWith(
          current: i + 1,
          progress: ((i + 1) / ayahUrls.length),
        );
      }

      state = state.copyWith(
        status: DownloadStatus.done,
        message: 'اكتمل التنزيل',
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = state.copyWith(
          status: DownloadStatus.cancelled,
          message: 'تم الإلغاء',
        );
      } else {
        state = state.copyWith(
          status: DownloadStatus.error,
          message: e.message,
        );
      }
    } catch (e) {
      state = state.copyWith(status: DownloadStatus.error, message: '$e');
    }
  }

  void cancel() {
    _token?.cancel('user_cancel');
  }
}

final downloadControllerProvider =
    StateNotifierProvider.autoDispose<DownloadController, DownloadState>(
      (ref) => DownloadController(ref),
    );
