import 'dart:math';

import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/screens/todayWeather/model.dart';
import 'package:client/screens/todayWeather/viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherByLocationProvider);
    final hourlyWeather = ref.watch(hourlyWeatherProvider);
    final dailyForecast = ref.watch(dailyWeatherProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          SvgPicture.asset(
            'assets/icons/bell.svg',
            color: HowWeatherColor.white,
          ),
          SizedBox(
            width: 8,
          ),
          SvgPicture.asset('assets/icons/settings.svg'),
          SizedBox(
            width: 24,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF4093EB), const Color(0xFFABDAEF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: weatherAsync.when(
              data: (weather) => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semibold_24px(
                            text: weather.name,
                            color: HowWeatherColor.white,
                          ),
                          Bold_64px(
                            text: '${weather.temperature.toStringAsFixed(0)}°',
                            color: HowWeatherColor.white,
                          ),
                          Medium_20px(
                            text: weather.description,
                            color: HowWeatherColor.white,
                          ),
                        ],
                      ),
                      Image.network(
                          scale: 0.8,
                          'http://openweathermap.org/img/wn/${weather.icon}@2x.png'),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  hourlyWeather.when(
                    data: (hourlyData) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: HowWeatherColor.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Medium_16px(
                                text: '오늘의 날씨 예보',
                                color: HowWeatherColor.white,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(
                                height: 1,
                                color: HowWeatherColor.white.withOpacity(0.5),
                              ),
                            ),
                            HourlyTemperatureChart(hourlyData: hourlyData),
                          ],
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('에러 발생: $e'),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  dailyForecast.when(
                    data: (forecastList) => Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: HowWeatherColor.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Medium_16px(
                              text: '주간 날씨 예보',
                              color: HowWeatherColor.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Divider(
                              height: 1,
                              color: HowWeatherColor.white.withOpacity(0.5),
                            ),
                          ),
                          WeeklyForecastList(dailyForecast: forecastList),
                        ],
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('에러: $e'),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
              loading: () => CircularProgressIndicator(),
              error: (e, _) => Text('에러: $e'),
            ),
          ),
        ),
      ),
    );
  }
}

class HourlyTemperatureChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;

  const HourlyTemperatureChart({super.key, required this.hourlyData});

  static const double columnWidth = 60.0;
  static const double graphHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final minTemp = hourlyData.map((e) => e.temperature).reduce(min) - 5;
    final maxTemp = hourlyData.map((e) => e.temperature).reduce(max) + 5;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: hourlyData.length * columnWidth,
        child: Stack(
          children: [
            // 📌 그래프
            Positioned(
              top: 84,
              left: 26,
              child: SizedBox(
                height: graphHeight,
                width: hourlyData.length * columnWidth * 0.84,
                child: LineChart(
                  LineChartData(
                    minY: minTemp,
                    maxY: maxTemp,
                    minX: 0,
                    maxX: (hourlyData.length - 1) * columnWidth,
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: hourlyData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return FlSpot(index * columnWidth, data.temperature);
                        }).toList(),
                        color: Colors.white,
                        barWidth: 1,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // 📌 텍스트, 아이콘, 온도, 습도
            Row(
              children: hourlyData.map((data) {
                return SizedBox(
                  width: columnWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Medium_14px(
                        text: '${data.dateTime.hour}시',
                        color: HowWeatherColor.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 4),
                      Image.network(
                        'http://openweathermap.org/img/wn/${data.icon}@2x.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(height: 4),
                      Medium_16px(
                        text: '${data.temperature.toStringAsFixed(0)}°',
                        color: HowWeatherColor.white,
                      ),
                      const SizedBox(height: graphHeight),
                      const SizedBox(height: 8),
                      Medium_14px(
                        text: '${data.precipitation.toStringAsFixed(0)}%',
                        color: HowWeatherColor.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyForecastList extends StatelessWidget {
  final List<DailyWeather> dailyForecast; // 8개 (어제~6일 뒤)

  const WeeklyForecastList({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: dailyForecast.map((data) {
        final dayLabel = getDayLabel(data.dateTime);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 날짜
              SizedBox(
                width: 60,
                child: Medium_14px(
                  text: dayLabel,
                  color: HowWeatherColor.white,
                ),
              ),
              Spacer(),
              // 습도
              SizedBox(
                width: 40,
                child: Center(
                  child: Medium_14px(
                    text: '${data.humidity}%',
                    color: HowWeatherColor.white.withOpacity(0.6),
                  ),
                ),
              ),
              // 날씨 아이콘
              SizedBox(
                width: 50,
                child: Image.network(
                  'http://openweathermap.org/img/wn/${data.icon}@2x.png',
                  width: 30,
                  height: 30,
                ),
              ),
              // 최고 기온
              SizedBox(
                width: 50,
                child: Center(
                  child: Medium_14px(
                    text: '${data.maxTemp.toStringAsFixed(0)}°',
                    color: HowWeatherColor.white,
                  ),
                ),
              ),
              // 최저 기온
              SizedBox(
                width: 50,
                child: Center(
                  child: Medium_14px(
                    text: '${data.minTemp.toStringAsFixed(0)}°',
                    color: HowWeatherColor.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String getDayLabel(DateTime dateTime) {
    final now = DateTime.now();

    // 날짜 간 비교를 위해 시간 부분 제거
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final diff = targetDate.difference(today).inDays;

    if (diff < 0) return '어제';
    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';

    // 요일 배열 - Dart에서 weekday는 월요일=1, 일요일=7
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${weekdays[dateTime.weekday - 1]}요일';
  }
}
