// lib/services/post_service.dart


import 'package:dio/dio.dart';
import 'package:dio_demo/services/api_client.dart';

class PostService {
  final ApiClient _apiClient;

  PostService(this._apiClient);

  Future<Map<String, dynamic>> getPost(int id) async {
    final response = await _apiClient.get('/posts/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    final response = await _apiClient.post('/posts', data: postData);
    return response.data as Map<String, dynamic>;
  }

  Future<void> testTimeout() async {
    try {
      // This will hit a non-existent endpoint with a very short timeout
      // to demonstrate connectionTimeout or receiveTimeout.
      await _apiClient.get(
        '/slow-endpoint',
        options: Options(
          sendTimeout: const Duration(milliseconds: 500),
          receiveTimeout: const Duration(milliseconds: 500),
          // connectTimeout: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      // Re-throw the error so the UI can handle it
      rethrow;
    }
  }
}
