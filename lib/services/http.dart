import 'package:http/http.dart' as http;

Future<void> fetchData() async {
  try {
    final response = await http.get(
      Uri.parse('http://endpoint.example.com/data'),
    );
    if (response.statusCode == 200) {
      print('Data fetched successfully: ${response.body}');
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }
}
