import '../web_services/web_services.dart';
import '../models/api_model.dart';

class Repository {
  final WebServices webServices;

  Repository(this.webServices);

  Future<List<ApiModel>> getAllPosts() async {
    final posts = await webServices.getAllPosts();
    return posts.map((post) => ApiModel.fromJson(post)).toList();
  }

  // Example for sending data
  Future<void> createPost(ApiModel post) async {
    await webServices.createPost(post.toJson());
  }
}
