import 'package:client/screens/todayWeather/model.dart';
import 'package:client/screens/todayWeather/repository.dart';
import 'package:client/service/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

final weatherByLocationProvider = FutureProvider<Weather>((ref) async {
  final repo = WeatherRepository(apiKey: apiKey);
  final locationService = LocationService();

  final position = await locationService.getCurrentLocation();
  return await repo.fetchWeatherByLocation(
      position.latitude, position.longitude);
});

final hourlyWeatherProvider = FutureProvider<List<HourlyWeather>>((ref) async {
  final repo = WeatherRepository(apiKey: apiKey);
  final locationService = LocationService();
  final position = await locationService.getCurrentLocation();
  return await repo.fetchHourlyWeather(position.latitude, position.longitude);
});

final dailyWeatherProvider = FutureProvider<List<DailyWeather>>((ref) async {
  final repo = WeatherRepository(apiKey: apiKey);
  final locationService = LocationService();

  final position = await locationService.getCurrentLocation();
  return await repo.fetchDailyWeather(position.latitude, position.longitude);
});
