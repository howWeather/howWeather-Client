import 'package:client/model/weather.dart';
import 'package:client/api/weather/weather_repository.dart';
import 'package:client/service/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

// 단일 LocationService 인스턴스를 제공하는 Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// 위치 정보를 제공하는 Provider
final locationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// 위치 정보를 사용하는 다른 Provider들이 locationProvider에 의존
final weatherByLocationProvider = FutureProvider<Weather>((ref) async {
  final repo = WeatherRepository(apiKey: apiKey);
  final position = await ref.watch(locationProvider.future);

  return await repo.fetchWeatherByLocation(
      position.latitude, position.longitude);
});

final hourlyWeatherProvider = FutureProvider<List<HourlyWeather>>((ref) async {
  final repo = WeatherRepository(apiKey: apiKey);
  final position = await ref.watch(locationProvider.future);

  return await repo.fetchHourlyWeather(position.latitude, position.longitude);
});

final dailyWeatherProvider = FutureProvider<List<DailyWeather>>((ref) async {
  final repo = WeatherRepository(apiKey: apiKey);
  final position = await ref.watch(locationProvider.future);

  return await repo.fetchDailyWeather(position.latitude, position.longitude);
});

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<double>>(
        (ref) => WeatherNotifier());

class WeatherNotifier extends StateNotifier<AsyncValue<double>> {
  WeatherNotifier() : super(const AsyncValue.loading());

  /// 지역/시간대/날짜에 따른 기온 불러오기
  Future<void> fetchTemperature({
    required String city,
    required int timeSlot,
    required String date,
  }) async {
    try {
      final repo = WeatherRepository();
      final temp = await repo.getTemperature(
        city: city,
        timeSlot: timeSlot,
        date: date,
      );
      state = AsyncValue.data(temp);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
