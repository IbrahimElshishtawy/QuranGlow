enum DownloadStatus { queued, running, completed, failed, canceled }

class DownloadJob {
  final String id;
  final String url;
  final String filePath;
  final int progress; // 0-100
  final DownloadStatus status;

  DownloadJob({
    required this.id,
    required this.url,
    required this.filePath,
    this.progress = 0,
    this.status = DownloadStatus.queued,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'url': url,
    'filePath': filePath,
    'progress': progress,
    'status': status.toString(),
  };
}
