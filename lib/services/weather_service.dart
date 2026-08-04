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
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchByLocation(double lat, double lon) async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // City search (OpenWeatherMap Geocoding)
  Future<List<Map<String, dynamic>>> searchCity(String query) async {
    try {
      final url =
          "https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
