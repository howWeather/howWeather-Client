import 'dart:convert';
import 'dart:math';
import 'package:client/model/weather.dart';
import 'package:http/http.dart' as http;

class WeatherRepository {
  final String apiKey;

  WeatherRepository({required this.apiKey});

  /// 한글 도시 이름 가져오기
  Future<String> fetchKoreanCityName(String city) async {
    final url = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$apiKey&lang=kr',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty && data[0]['local_names'] != null) {
        return data[0]['local_names']['ko'] ?? city;
      } else {
        return city;
      }
    } else {
      throw Exception('한글 도시 이름을 가져오지 못했습니다.');
    }
  }

  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final name = data['name'] ?? '';
      final koreanName =
          await fetchKoreanCityName(name); // 위도 기반일 때도 한글 이름으로 변환
      return Weather.fromJson(data, koreanName);
    } else {
      throw Exception('위치 기반 날씨 데이터를 가져오지 못했습니다.');
    }
  }

  Future<List<HourlyWeather>> fetchHourlyWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['list'];

      final now = DateTime.now();
      final tomorrow = now.add(Duration(days: 1));

      final todayOrTomorrowForecast =
          list.map((item) => HourlyWeather.fromJson(item)).where((weather) {
        final date = weather.dateTime;
        return (date.year == now.year &&
                date.month == now.month &&
                date.day == now.day) ||
            (date.year == tomorrow.year &&
                date.month == tomorrow.month &&
                date.day == tomorrow.day);
      }).toList();

      return todayOrTomorrowForecast;
    } else {
      throw Exception('시간별 날씨 데이터를 가져오지 못했습니다.');
    }
  }

  Future<List<DailyWeather>> fetchDailyWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey&lang=kr';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list']; // 3시간 간격 데이터

      final Map<String, List<Map<String, dynamic>>> groupedByDay = {};

      for (final item in list) {
        final date = DateTime.parse(item['dt_txt']).toLocal();
        final key = '${date.year}-${date.month}-${date.day}';
        groupedByDay.putIfAbsent(key, () => []).add(item);
      }

      return groupedByDay.entries.take(8).map((entry) {
        final items = entry.value;
        final date = DateTime.parse(items[0]['dt_txt']);

        final temps = items.map((e) => e['main']['temp'] as num).toList();
        final humidities =
            items.map((e) => e['main']['humidity'] as num).toList();
        final icons =
            items.map((e) => e['weather'][0]['icon'] as String).toList();

        return DailyWeather(
          dateTime: date,
          humidity: humidities.reduce((a, b) => a + b) ~/ humidities.length,
          icon: icons[0], // 첫 시간대 아이콘 사용
          maxTemp: temps.reduce(max).toDouble(),
          minTemp: temps.reduce(min).toDouble(),
        );
      }).toList();
    } else {
      throw Exception('Failed to load daily weather');
    }
  }
}
