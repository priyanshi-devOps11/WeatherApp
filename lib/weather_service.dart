import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey = '0b8cb3ca16665a68aa5c4c4a7d0f8daa';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<WeatherData> getWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception('City not found');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<List<ForecastData>> getForecast(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$forecastUrl?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<ForecastData> forecasts = [];

        for (var item in data['list']) {
          forecasts.add(ForecastData.fromJson(item));
        }

        return forecasts;
      } else {
        throw Exception('Forecast not found');
      }
    } catch (e) {
      throw Exception('Failed to load forecast data: $e');
    }
  }
}

class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int cloudiness;
  final String description;
  final String mainCondition;
  final String icon;
  final int sunrise;
  final int sunset;
  final int timezone;
  final DateTime dateTime;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.cloudiness,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
    required this.dateTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      pressure: json['main']['pressure'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      cloudiness: json['clouds']['all'] ?? 0,
      description: json['weather'][0]['description'] ?? 'Unknown',
      mainCondition: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      sunrise: json['sys']['sunrise'] ?? 0,
      sunset: json['sys']['sunset'] ?? 0,
      timezone: json['timezone'] ?? 0,
      dateTime: DateTime.now(),
    );
  }

  String getLocalTime() {
    final localTime = dateTime.add(Duration(seconds: timezone));
    return DateFormat('hh:mm a').format(localTime);
  }

  String getLocalDate() {
    final localTime = dateTime.add(Duration(seconds: timezone));
    return DateFormat('EEEE, MMM dd').format(localTime);
  }

  String getSunriseTime() {
    final time = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
    return DateFormat('hh:mm a').format(time);
  }

  String getSunsetTime() {
    final time = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
    return DateFormat('hh:mm a').format(time);
  }
}

class ForecastData {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;

  ForecastData({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
  });
  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
    );
  }
}
