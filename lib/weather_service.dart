import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '0b8cb3ca16665a68aa5c4c4a7d0f8daa';  // Replace with your OpenWeather API key
  final String baseUrl = 'http://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
