// lib/screens/dio_demo_screen.dart
import 'package:dio_demo/services/api_client.dart';
import 'package:dio_demo/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class DioDemoScreen extends StatefulWidget {
  final ApiClient apiClient;
  const DioDemoScreen({super.key, required this.apiClient});

  @override
  State<DioDemoScreen> createState() => _DioDemoScreenState();
}

class _DioDemoScreenState extends State<DioDemoScreen> {
  String _responseMessage = '';
  bool _isLoading = false;
  final TextEditingController _postTitleController = TextEditingController(text: 'My New Post');
  final TextEditingController _postBodyController = TextEditingController(text: 'This is the content of my new post.');

  late PostService _postService;

  @override
  void initState() {
    super.initState();
    _postService = PostService(widget.apiClient);
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      final post = await _postService.getPost(1);
      setState(() {
        _responseMessage = 'GET Success!\nTitle: ${post['title']}\nBody: ${post['body']}';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'GET Request');
    } catch (e) {
      _handleGenericError(e, 'GET Request');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _postNewData() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    final postPayload = {
      'title': _postTitleController.text,
      'body': _postBodyController.text,
      'userId': 1, // Example user ID
    };
    try {
      final newPost = await _postService.createPost(postPayload);
      setState(() {
        _responseMessage = 'POST Success!\nID: ${newPost['id']}\nTitle: ${newPost['title']}';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'POST Request');
    } catch (e) {
      _handleGenericError(e, 'POST Request');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _demonstrateTimeout() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });
    try {
      // This will attempt to hit a non-existent endpoint with a very short timeout
      // to demonstrate the connectionTimeout or receiveTimeout.
      await _postService.testTimeout();
      setState(() {
        _responseMessage = 'Timeout Test Success (unexpected)!';
      });
    } on DioException catch (e) {
      _handleDioError(e, 'Timeout Test');
    } catch (e) {
      _handleGenericError(e, 'Timeout Test');
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
        break;
      case DioExceptionType.connectionError:
        message += 'Connection Error: Could not connect to the server. Check your network.';
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
        title: const Text('Dio Capabilities Demo'),
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
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Explore Dio Features',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 1, // Changed to 1 for better mobile layout, can be 2 for wider screens
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 4 / 1, // Adjust aspect ratio for buttons
                  children: [
                    _buildActionButton(
                      text: _isLoading ? 'Fetching...' : 'GET Data (posts/1)',
                      color: const Color(0xFF2563EB),
                      onPressed: _isLoading ? null : _fetchData,
                    ),
                    _buildActionButton(
                      text: _isLoading ? 'Posting...' : 'POST Data (new post)',
                      color: const Color(0xFF16A34A),
                      onPressed: _isLoading ? null : _postNewData,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postTitleController,
                  decoration: InputDecoration(
                    hintText: 'Post Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _postBodyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Post Body',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  text: _isLoading ? 'Testing Timeout...' : 'Test Timeout (500ms)',
                  color: const Color(0xFFDC2626),
                  onPressed: _isLoading ? null : _demonstrateTimeout,
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
                            fontFamily: 'monospace', // For better readability of JSON
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                // const SizedBox(height: 24),
                // const Text(
                //   'Check your IDE console for Interceptor logs!',
                //   style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
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
              return Colors.white.withOpacity(0.2); // Ripple effect color
            }
            return null; // Defer to the widget's default.
          },
        ),
      ),
      child: Text(text),
    );
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postBodyController.dispose();
    super.dispose();
  }
}
