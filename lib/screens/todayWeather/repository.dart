import 'dart:convert';
import 'package:client/screens/todayWeather/model.dart';
import 'package:http/http.dart' as http;

class WeatherRepository {
  final String apiKey;

  WeatherRepository({required this.apiKey});

  Future<Weather> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return Weather.fromJson(data);
    } else {
      throw Exception('위치 기반 날씨 데이터를 가져오지 못했습니다.');
    }
  }

  Future<List<HourlyWeather>> fetchHourlyWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['list'];

      final now = DateTime.now();
      final today = now.day;

      final todayForecast = list
          .map((item) => HourlyWeather.fromJson(item))
          .where((weather) => weather.dateTime.day == today)
          .toList();

      return todayForecast;
    } else {
      throw Exception('시간별 날씨 데이터를 가져오지 못했습니다.');
    }
  }
}
