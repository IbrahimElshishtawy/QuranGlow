import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {
  Future<String> downloadFile(
    String url,
    String filename,
    void Function(int, int)? onProgress,
  ) async {
    final client = http.Client();
    final req = await client.send(http.Request('GET', Uri.parse(url)));
    final total = req.contentLength ?? 0;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    final sink = file.openWrite();
    int received = 0;
    await for (final chunk in req.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (onProgress != null) onProgress(received, total);
    }
    await sink.flush();
    await sink.close();
    return file.path;
  }
}
