import 'package:dio_demo/services/api_client.dart';
import 'package:dio_demo/services/food_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'package:dio_demo_app/services/api_client.dart';
// import 'package:dio_demo_app/services/food_service.dart'; // Changed from post_service.dart

class DioDemoScreen extends StatefulWidget {
  final ApiClient apiClient;
  const DioDemoScreen({super.key, required this.apiClient});

  @override
  State<DioDemoScreen> createState() => _DioDemoScreenState();
}

class _DioDemoScreenState extends State<DioDemoScreen> {
  String _responseMessage = '';
  bool _isLoading = false;
  String? _accessToken;
  String? _refreshToken;

  // Controllers for Login
  final TextEditingController _loginUsernameController = TextEditingController(text: 'testuser');
  final TextEditingController _loginPasswordController = TextEditingController(text: 'password123');

  // Controllers for Registration
  final TextEditingController _regUsernameController = TextEditingController(text: 'newuser');
  final TextEditingController _regEmailController = TextEditingController(text: 'newuser@example.com');
  final TextEditingController _regPasswordController = TextEditingController(text: 'securepassword');

  // Controllers for Create Food
  final TextEditingController _createFoodTitleController = TextEditingController(text: 'Sample Food');
  final TextEditingController _createFoodPriceController = TextEditingController(text: '12.99');
  final TextEditingController _createFoodCategoryController = TextEditingController(text: 'main');

  // Controller for Food Search
  final TextEditingController _searchQueryController = TextEditingController();
  final TextEditingController _searchCategoryController = TextEditingController();


  late FoodService _foodService; // Changed from _postService

  @override
  void initState() {
    super.initState();
    _foodService = FoodService(widget.apiClient); // Changed from PostService
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final result = await _foodService.login(
        _loginUsernameController.text,
        _loginPasswordController.text,
      );
      setState(() {
        _accessToken = result['token']['access_token'];
        _refreshToken = result['token']['refresh_token'];
        _responseMessage = 'Login Success!\nUser: ${result['user']['username']}\nAccess Token: $_accessToken\nRefresh Token: $_refreshToken';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Login');
    } catch (e) {
      _handleGenericError(e, 'Login');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final result = await _foodService.register(
        _regUsernameController.text,
        _regEmailController.text,
        _regPasswordController.text,
      );
      setState(() {
        _accessToken = result['token']['access_token'];
        _refreshToken = result['token']['refresh_token'];
        _responseMessage = 'Registration Success!\nUser: ${result['user']['username']}\nAccess Token: $_accessToken\nRefresh Token: $_refreshToken';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Registration');
    } catch (e) {
      _handleGenericError(e, 'Registration');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getFoods() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final foods = await _foodService.getFoods();
      setState(() {
        _responseMessage = 'Get All Foods Success!\nFoods: ${foods.map((f) => f['title']).join(', ')}';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Get Foods');
    } catch (e) {
      _handleGenericError(e, 'Get Foods');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getFoodById(int id) async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final food = await _foodService.getFood(id);
      setState(() {
        _responseMessage = 'Get Food by ID ($id) Success!\nTitle: ${food['title']}\nPrice: \$${food['price']}';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Get Food by ID');
    } catch (e) {
      _handleGenericError(e, 'Get Food by ID');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createFood() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final newFood = await _foodService.createFood(
        _createFoodTitleController.text,
        double.parse(_createFoodPriceController.text),
        _createFoodCategoryController.text,
      );
      setState(() {
        _responseMessage = 'Create Food Success!\nID: ${newFood['id']}\nTitle: ${newFood['title']}';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Create Food');
    } catch (e) {
      _handleGenericError(e, 'Create Food');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFoods() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final foods = await _foodService.searchFoods(
        query: _searchQueryController.text.isEmpty ? null : _searchQueryController.text,
        category: _searchCategoryController.text.isEmpty ? null : _searchCategoryController.text,
      );
      setState(() {
        if (foods.isNotEmpty) {
          _responseMessage = 'Search Foods Success!\nFound: ${foods.map((f) => f['title']).join(', ')}';
        } else {
          _responseMessage = 'Search Foods Success!\nNo foods found matching criteria.';
        }
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Search Foods');
    } catch (e) {
      _handleGenericError(e, 'Search Foods');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _handleDioError(DioException error, String requestType) {
    String message = 'Error during $requestType:\n';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message += 'Connection Timeout: The server did not respond in time.';
        break;
      case DioExceptionType.receiveTimeout:
        message += 'Receive Timeout: The server took too long to send data.';
        break;
      case DioExceptionType.badResponse:
        message += 'Bad Response: Status ${error.response?.statusCode ?? 'N/A'}. ${error.message}';
        // If there's a specific error message from the backend, include it
        if (error.response?.data != null && error.response?.data is Map) {
          message += '\nBackend Error: ${error.response!.data.toString()}';
        }
        break;
      case DioExceptionType.connectionError:
        message += 'Connection Error: Could not connect to the server. Check your network or server status.';
        break;
      case DioExceptionType.cancel:
        message += 'Request Cancelled.';
        break;
      case DioExceptionType.unknown:
      default:
        message += 'Unknown Dio Error: ${error.message}';
    }
    if (error.error != null) {
      message += '\nDetails: ${error.error.toString()}';
    }
    setState(() {
      _responseMessage = message;
    });
  }

  void _handleGenericError(Object error, String requestType) {
    setState(() {
      _responseMessage = 'An unexpected error occurred during $requestType: ${error.toString()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dio Demo with Django API'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'User Authentication',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 16),
                _buildTextField(_loginUsernameController, 'Login Username'),
                const SizedBox(height: 8),
                _buildTextField(_loginPasswordController, 'Login Password', obscureText: true),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Logging In...' : 'Login',
                  color: Colors.deepPurple,
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 24),
                _buildTextField(_regUsernameController, 'Register Username'),
                const SizedBox(height: 8),
                _buildTextField(_regEmailController, 'Register Email'),
                const SizedBox(height: 8),
                _buildTextField(_regPasswordController, 'Register Password', obscureText: true),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Registering...' : 'Register',
                  color: Colors.indigo,
                  onPressed: _isLoading ? null : _register,
                ),
                const Divider(height: 48, thickness: 1),
                const Text(
                  'Food Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Fetching Foods...' : 'Get All Foods',
                  color: const Color(0xFF2563EB),
                  onPressed: _isLoading ? null : _getFoods,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Fetching Food (ID 1)...' : 'Get Food by ID (1)',
                  color: const Color(0xFF16A34A),
                  onPressed: _isLoading ? null : () => _getFoodById(1),
                ),
                const SizedBox(height: 24),
                _buildTextField(_createFoodTitleController, 'New Food Title'),
                const SizedBox(height: 8),
                _buildTextField(_createFoodPriceController, 'New Food Price', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField(_createFoodCategoryController, 'New Food Category'),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Creating Food...' : 'Create Food',
                  color: Colors.orange,
                  onPressed: _isLoading ? null : _createFood,
                ),
                const Divider(height: 48, thickness: 1),
                const Text(
                  'Food Search',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 16),
                _buildTextField(_searchQueryController, 'Search Query (e.g., "pizza")'),
                const SizedBox(height: 8),
                _buildTextField(_searchCategoryController, 'Search Category (e.g., "main")'),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Searching...' : 'Search Foods',
                  color: Colors.teal,
                  onPressed: _isLoading ? null : _searchFoods,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333333)),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(color: Color(0xFF555555)),
                        ),
                      ],
                    ),
                  ),
                if (_responseMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Response:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _responseMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontFamily: 'monospace',
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Check your IDE console for Interceptor logs!',
                  style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Remember to set the correct base URL in api_client.dart (e.g., http://10.0.2.2:8000 for Android emulator).',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.2);
            }
            return null;
          },
        ),
      ),
      child: Text(text),
    );
  }

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _createFoodTitleController.dispose();
    _createFoodPriceController.dispose();
    _createFoodCategoryController.dispose();
    _searchQueryController.dispose();
    _searchCategoryController.dispose();
    super.dispose();
  }
}
