import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "764b8ca9b084145040e857d9206d2c49";

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['cod'] == "200") {
          return data;
        } else {
          print("API error: ${data['message']}");
          return null;
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Network error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchByLocation(double lat, double lon) async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['cod'] == "200") {
          return data;
        } else {
          print("API error: ${data['message']}");
          return null;
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Network error: $e");
      return null;
    }
  }
}
