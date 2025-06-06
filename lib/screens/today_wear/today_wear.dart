import 'dart:math';

import 'package:client/api/cloth/cloth_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/weather.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:client/screens/skeleton/wear_skeleton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class TodayWear extends ConsumerWidget {
  const TodayWear({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourlyWeather = ref.watch(hourlyWeatherProvider);
    final upperClothImageAsync =
        ref.read(clothViewModelProvider.notifier).getUpperClothImage(3);
    final imageAsync = ref.watch(clothViewModelProvider);

    return hourlyWeather.when(
      data: (hourlyData) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF4093EB), const Color(0xFFABDAEF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Semibold_24px(
                text: "오늘 날씨에 추천하는 옷이에요!",
                color: HowWeatherColor.white,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Semibold_20px(
                        text: "추천 상의",
                        color: HowWeatherColor.white,
                      ),
                      imageAsync.when(
                        data: (url) => Image.network(
                          url,
                          width: MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.fill,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => const Icon(Icons.error),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Semibold_20px(
                        text: "추천 아우터",
                        color: HowWeatherColor.white,
                      ),
                      imageAsync.when(
                        data: (url) => Image.network(
                          url,
                          width: MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.fill,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => const Icon(Icons.error),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: HowWeatherColor.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Medium_16px(
                            text: '체감별 날씨 그래프',
                            color: HowWeatherColor.white,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: HowWeatherColor.secondary[800],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Medium_14px(
                          text: "더움",
                          color: HowWeatherColor.white,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: HowWeatherColor.secondary[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Medium_14px(
                          text: "적당",
                          color: HowWeatherColor.white,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: HowWeatherColor.primary[800],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Medium_14px(
                          text: "추움",
                          color: HowWeatherColor.white,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(
                        height: 1,
                        color: HowWeatherColor.white.withOpacity(0.5),
                      ),
                    ),
                    PerceivedTemperatureChart(hourlyData: hourlyData),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => TodayWearSkeleton(),
      error: (e, st) => Text('에러 발생: $e'),
    );
  }
}

class PerceivedTemperatureChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;

  const PerceivedTemperatureChart({super.key, required this.hourlyData});

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
              top: 20,
              left: columnWidth / 2, // 첫 번째 열의 중앙에서 시작
              right: columnWidth / 2, // 마지막 열의 중앙에서 끝
              height: graphHeight,
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
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final temp = hourlyData[index].temperature;
                          final color = temp > 30
                              ? HowWeatherColor.secondary[800]!
                              : temp >= 15
                                  ? HowWeatherColor.secondary[500]!
                                  : HowWeatherColor.primary[800]!;

                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeColor: Colors.transparent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    )
                  ],
                ),
              ),
            ),

            // 📌 텍스트, 아이콘, 온도, 습도
            Row(
              children: hourlyData.map((data) {
                return SizedBox(
                  width: columnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Medium_16px(
                        text: '${data.temperature.toStringAsFixed(0)}°',
                        color: HowWeatherColor.white,
                      ),
                      const SizedBox(height: graphHeight),
                      Medium_14px(
                        text: '${data.dateTime.hour}시',
                        color: HowWeatherColor.white.withOpacity(0.8),
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
