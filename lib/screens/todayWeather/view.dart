import 'package:client/screens/todayWeather/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherByLocationProvider);

    return Scaffold(
      body: Center(
        child: weatherAsync.when(
          data: (weather) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('현재 위치 날씨', style: TextStyle(fontSize: 20)),
              Image.network(
                  'http://openweathermap.org/img/wn/${weather.icon}@2x.png'),
              Text(weather.description),
              Text('${weather.temperature}°C'),
            ],
          ),
          loading: () => CircularProgressIndicator(),
          error: (e, _) => Text('에러: $e'),
        ),
      ),
    );
  }
}
