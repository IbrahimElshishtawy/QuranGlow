import 'package:dio/dio.dart';
import '../utils/logger.dart';

class HttpClient {
  final Dio dio;
  HttpClient._(this.dio);

  factory HttpClient({BaseOptions? options}) {
    final dio = Dio(
      options ?? BaseOptions(connectTimeout: 15000, receiveTimeout: 15000),
    );
    dio.interceptors.add(
      LogInterceptor(responseBody: false, requestBody: false),
    );
    // simple retry interceptor (1 retry)
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) async {
          final r = e.requestOptions;
          final retries = r.extra['retries'] as int? ?? 0;
          if (retries < 1) {
            r.extra['retries'] = retries + 1;
            try {
              final resp = await dio.request(
                r.path,
                data: r.data,
                queryParameters: r.queryParameters,
                options: Options(method: r.method, headers: r.headers),
              );
              return handler.resolve(resp);
            } catch (err) {
              L.e('HttpClient', err, e.stackTrace);
            }
          }
          return handler.next(e);
        },
      ),
    );
    return HttpClient._(dio);
  }
}
