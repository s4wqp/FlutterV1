import 'package:dio/dio.dart';
import 'dart:io';
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

  Future<Response> registerUser(
      Map<String, dynamic> data, Map<String, File> files) async {
    try {
      FormData formData = FormData.fromMap(data);

      for (var entry in files.entries) {
        String key = entry.key;
        File file = entry.value;
        // Use minimal filename length (e.g., "1.jpg", "2.jpg") to avoid DB limit
        // The previous attempt (key.ext) resulted in ~17 chars which was too long for 'user_id_photo' column.
        int index = files.keys.toList().indexOf(key);
        String ext = file.path.split('.').last;
        if (ext.length > 4) ext = 'jpg';
        String fileName = "${index + 1}.$ext";

        print(
            "DEBUG: Adding file field: '$key' with filename: '$fileName'"); // DEBUG LOG

        formData.files.add(MapEntry(
          key,
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      Response response = await dio.post('users', data: formData);
      return response;
    } catch (e) {
      print("Register User Error: $e");
      rethrow;
    }
  }
}
