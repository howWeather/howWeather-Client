import 'dart:math';

import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/weather.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:client/screens/skeleton/weather_skeleton.dart';
import 'package:client/service/location_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  Future<void> _handleLocationError(BuildContext context, dynamic error) async {
    print('WeatherScreen 에러 발생: $error');

    try {
      // LocationService를 사용하여 위치 사용 가능성 확인
      final locationService = LocationService();
      bool isLocationAvailable = await locationService.isLocationAvailable();

      print('위치 사용 가능: $isLocationAvailable');

      if (isLocationAvailable) {
        print('위치 사용 가능 - LocationService 문제로 판단하여 재시도');

        // LocationService 캐시 초기화
        locationService.clearCache();

        // 잠시 대기 후 자동 재시도
        await Future.delayed(Duration(milliseconds: 1000));
        return; // 자동 재시도를 위해 return
      }

      // 위치를 사용할 수 없는 경우에만 NoLocationPermission으로 이동
      print('위치 사용 불가 - NoLocationPermission으로 이동');
      GoRouter.of(context)
          .go('/no-location-permission', extra: error.toString());
    } catch (e) {
      print('에러 처리 중 예외 발생: $e');
      // 권한 확인 자체가 실패한 경우 NoLocationPermission으로 이동
      GoRouter.of(context)
          .go('/no-location-permission', extra: error.toString());
    }
  }

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
                    error: (e, st) => Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text(
                            '시간별 날씨를 불러올 수 없습니다',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
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
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text(
                            '주간 날씨를 불러올 수 없습니다',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
              // loading: () => Container(
              //   height: MediaQuery.of(context).size.height,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       CircularProgressIndicator(color: Colors.white),
              //       SizedBox(height: 16),
              //       Text(
              //         '날씨 정보를 불러오는 중...',
              //         style: TextStyle(color: Colors.white70),
              //       ),
              //     ],
              //   ),
              // ),
              loading: () => WeatherSkeletonScreen(),
              error: (e, st) {
                // 에러 처리를 위한 PostFrameCallback
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!context.mounted) return;

                  await _handleLocationError(context, e);

                  // 위치가 사용 가능한 경우 자동 재시도
                  final locationService = LocationService();
                  bool isLocationAvailable =
                      await locationService.isLocationAvailable();

                  if (isLocationAvailable && context.mounted) {
                    print('위치 사용 가능 확인됨 - Provider 새로고침');
                    // 짧은 대기 후 새로고침
                    Future.delayed(Duration(milliseconds: 1500), () {
                      if (context.mounted) {
                        ref.refresh(locationProvider);
                      }
                    });
                  }
                });

                // 에러 발생 시 임시 UI 표시
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        '날씨 정보를 불러오는 중입니다...',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '잠시만 기다려주세요',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Provider 새로고침
                          LocationService().clearCache();
                          ref.refresh(locationProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text('다시 시도'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
    final tempRange = maxTemp - minTemp;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: hourlyData.length * columnWidth,
        child: Column(
          children: [
            SizedBox(
              height: 220, // 전체 높이 조정
              child: Stack(
                children: [
                  // 시간, 아이콘, 온도 표시
                  Positioned.fill(
                    child: Row(
                      children: hourlyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
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
                              const SizedBox(height: 100), // 그래프와 습도 사이 간격 조정
                              Medium_14px(
                                text: '${data.humidity.toStringAsFixed(0)}%',
                                color: HowWeatherColor.white.withOpacity(0.5),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // 그래프 배치
                  Positioned(
                    top: 84, // 온도 표시와 정렬을 위한 상단 위치 조정
                    left: columnWidth / 2, // 첫 번째 열의 중앙에서 시작
                    right: columnWidth / 2, // 마지막 열의 중앙에서 끝
                    height: graphHeight,
                    child: LineChart(
                      LineChartData(
                        minY: minTemp,
                        maxY: maxTemp,
                        minX: 0,
                        maxX: hourlyData.length - 1,
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: hourlyData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              // 각 열의 중앙에 점 배치
                              return FlSpot(index.toDouble(), data.temperature);
                            }).toList(),
                            color: Colors.white,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 1,
                                  strokeColor: Colors.blue,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: false,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyForecastList extends StatelessWidget {
  final List<DailyWeather> dailyForecast;

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
