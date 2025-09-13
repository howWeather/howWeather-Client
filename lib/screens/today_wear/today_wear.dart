import 'dart:math';

import 'package:client/api/cloth/cloth_view_model.dart';
import 'package:client/api/model/model_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/weather.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:client/providers/location_provider.dart';
import 'package:client/screens/skeleton/wear_skeleton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class TodayWear extends ConsumerWidget {
  const TodayWear({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourlyWeather = ref.watch(hourlyWeatherProvider);
    final modelState = ref.watch(modelViewModelProvider);
    final currentUserLocation = ref.watch(userLocationProvider);

    ref.read(modelViewModelProvider.notifier).fetchRecommendation();

    return hourlyWeather.when(
      data: (hourlyData) {
        return SingleChildScrollView(
          child: Container(
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
                modelState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('문제가 발생했어요.\n$e'),
                  data: (recommendations) {
                    if (recommendations.isEmpty) {
                      return Semibold_18px(
                        text: "추천 가능한 옷이 없습니다. 새로운 옷을 추가해 보세요.",
                        color: HowWeatherColor.white,
                      );
                    }
                    final upperClothImageAsync =
                        recommendations.first.uppersTypeList.isNotEmpty
                            ? ref.watch(upperClothImageProvider(
                                recommendations.first.uppersTypeList.first))
                            : null;

                    final outerClothImageAsync =
                        recommendations.first.outersTypeList.isNotEmpty
                            ? ref.watch(outerClothImageProvider(
                                recommendations.first.outersTypeList.first))
                            : null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recommendations.first.uppersTypeList.isNotEmpty &&
                            upperClothImageAsync != null)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Semibold_20px(
                                text: "추천 상의",
                                color: HowWeatherColor.white,
                              ),
                              upperClothImageAsync.when(
                                data: (url) => Image.network(
                                  url,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  fit: BoxFit.fill,
                                ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (e, _) => const Icon(Icons.error),
                              ),
                            ],
                          ),
                        if (recommendations.first.outersTypeList.isNotEmpty &&
                            outerClothImageAsync != null)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Semibold_20px(
                                text: "추천 아우터",
                                color: HowWeatherColor.white,
                              ),
                              outerClothImageAsync.when(
                                data: (url) => Image.network(
                                  url,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  fit: BoxFit.fill,
                                ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (e, _) => const Icon(Icons.error),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                SizedBox(
                  height: 16,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semibold_16px(
                            text: '기준 지역',
                            color: HowWeatherColor.white,
                          ),
                          GestureDetector(
                            onTap: () async {
                              // 위치 선택 페이지로 이동
                              final selectedLocation =
                                  await context.push('/location-search');

                              // 위치가 선택되었을 때 서버에 업데이트
                              if (selectedLocation != null &&
                                  selectedLocation is String) {
                                try {
                                  await ref
                                      .read(locationViewModelProvider.notifier)
                                      .updateUserLocation(selectedLocation);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '위치가 "$selectedLocation"로 설정되었습니다.'),
                                        backgroundColor:
                                            HowWeatherColor.primary[600],
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '위치 설정에 실패했습니다: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: HowWeatherColor.white),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/locator.svg',
                                  ),
                                  SizedBox(width: 4),
                                  Semibold_16px(
                                    text: currentUserLocation ?? '서울특별시 용산구',
                                  ),
                                ],
                              ),
                            ),
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
                      Medium_14px(
                        text: '''기준 지역의 예보 데이터를 이용하여 의상을 추천합니다.
초기 설정은 서울특별시 용산구입니다.
오전 04:00 ~ 07:00 동안에는 지역 변경이 불가합니다.
지역 변경 시 다음 날부터 해당 지역의 예보 데이터로 예측을 진행합니다. ''',
                        color: HowWeatherColor.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => TodayWearSkeleton(),
      error: (e, st) => Text('에러 발생: $e'),
    );
  }
}

class PerceivedTemperatureChart extends ConsumerWidget {
  final List<HourlyWeather> hourlyData;

  const PerceivedTemperatureChart({super.key, required this.hourlyData});

  static const double columnWidth = 60.0;
  static const double graphHeight = 80.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minTemp = hourlyData.map((e) => e.temperature).reduce(min) - 5;
    final maxTemp = hourlyData.map((e) => e.temperature).reduce(max) + 5;
    final modelState = ref.watch(modelViewModelProvider);
    ref.read(modelViewModelProvider.notifier).fetchRecommendation();

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
                          return modelState.when(
                            loading: () => FlDotCirclePainter(
                              radius: 4,
                              color: HowWeatherColor.neutral[200]!,
                              strokeColor: Colors.transparent,
                            ),
                            error: (e, _) => FlDotCirclePainter(
                              radius: 4,
                              color: HowWeatherColor.neutral[200]!,
                              strokeColor: Colors.transparent,
                            ),
                            data: (recommendations) {
                              if (recommendations.length < 2) {
                                // fallback 처리
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: HowWeatherColor.neutral[200]!,
                                  strokeColor: Colors.transparent,
                                );
                              }

                              final allFeelingList = [
                                ...recommendations[0].feelingList,
                                ...recommendations[1].feelingList,
                              ];

                              if (index >= allFeelingList.length) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: HowWeatherColor.neutral[200]!,
                                  strokeColor: Colors.transparent,
                                );
                              }

                              final colorIndex = allFeelingList[index].feeling;

                              late Color color;
                              if (colorIndex == 1) {
                                color = HowWeatherColor.secondary[800]!;
                              } else if (colorIndex == 2) {
                                color = HowWeatherColor.secondary[500]!;
                              } else if (colorIndex == 3) {
                                color = HowWeatherColor.primary[800]!;
                              } else {
                                color = HowWeatherColor.neutral[200]!;
                              }

                              return FlDotCirclePainter(
                                radius: 4,
                                color: color,
                                strokeColor: Colors.transparent,
                              );
                            },
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
