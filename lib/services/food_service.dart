import 'package:dio/dio.dart';
import 'package:dio_demo/services/api_client.dart';

class FoodService {
  final ApiClient _apiClient;

  FoodService(this._apiClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiClient.post(
      'account/log',
      data: {
        'username': username,
        'password': password,
      },
    );
    return response.data['payload'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _apiClient.post(
      'account/register', 
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return response.data['payload'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getFoods() async {
    final response = await _apiClient.get('/foods/'); // Your Django getFoods endpoint
    return response.data['foods'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getFood(int id) async {
    final response = await _apiClient.get('/food/$id/'); // Your Django getFood endpoint
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createFood(String title, double price, String category) async {
    final response = await _apiClient.post(
      '/create_food/', // Your Django createFood endpoint
      data: {
        'title': title,
        'price': price,
        'category': category,
      },
      // You might need to add authorization header here if createFood requires it
      // options: Options(headers: {'Authorization': 'Bearer YOUR_ACCESS_TOKEN'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> searchFoods({String? query, String? category}) async {
    final Map<String, dynamic> queryParams = {};
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final response = await _apiClient.get(
      '/food/search', // Your Django food_search_view endpoint
      queryParameters: queryParams,
    );
    return response.data['foods'] as List<dynamic>;
  }

  Future<List<dynamic>> getRecommendedFoods() async {
    final response = await _apiClient.get('/recommended/'); // Your Django recommended endpoint
    return response.data['orders'] as List<dynamic>; // Note: Django API returns "orders" key here
  }
}
