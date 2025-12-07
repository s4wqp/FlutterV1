import 'package:dio/dio.dart';
import 'dio_factory.dart';

class WebServices {
  late Dio dio;

  WebServices() {
    dio = DioFactory.getDio();
  }

  Future<List<dynamic>> getAllPosts() async {
    try {
      Response response = await dio.get('posts');
      return response.data;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Example of sending data
  Future<Response> createPost(Map<String, dynamic> postData) async {
    try {
      Response response = await dio.post('posts', data: postData);
      return response;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
