import 'package:dio_demo/screens/dio_demo_seceen.dart';
import 'package:dio_demo/services/api_client.dart';
import 'package:flutter/material.dart';

void main() {
  // Initialize Dio client globally or pass it down via provider/get_it
  // For simplicity, we'll initialize it here and pass it to the screen.
  final ApiClient apiClient = ApiClient();
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Capabilities Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Assuming Inter font is available or fallbacks
        useMaterial3: true, // Use Material Design 3
      ),
      home: DioDemoScreen(apiClient: apiClient),
    );
  }
}
