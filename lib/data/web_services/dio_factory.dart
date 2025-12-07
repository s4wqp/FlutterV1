import 'package:dio/dio.dart';

class DioFactory {
  static Dio? dio;

  static Dio getDio() {
    if (dio == null) {
      dio = Dio();
      dio!.options.baseUrl =
          "https://jsonplaceholder.typicode.com/"; // Placeholder URL
      dio!.options.receiveTimeout = const Duration(seconds: 20);
      dio!.options.connectTimeout = const Duration(seconds: 20);
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
    return dio!;
  }
}
