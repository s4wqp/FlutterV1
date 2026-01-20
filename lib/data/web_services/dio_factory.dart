import 'package:dio/dio.dart';

class DioFactory {
  static Dio? dio;

  static Dio getDio() {
    if (dio == null) {
      dio = Dio();
      dio!.options.baseUrl = "https://api.aidme.online/api/";
      dio!.options.receiveTimeout = const Duration(seconds: 60);
      dio!.options.connectTimeout = const Duration(seconds: 60);
      dio!.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add interceptors if needed (e.g., for logging or auth tokens)
      dio!.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
    // Force update timeouts in case of Hot Reload
    dio!.options.receiveTimeout = const Duration(seconds: 120);
    dio!.options.connectTimeout = const Duration(seconds: 60);
    return dio!;
  }
}
