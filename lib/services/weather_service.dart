import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "1845fcc1ff3728d3512beb854aacbb7e";

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
