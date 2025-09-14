import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:client/designs/how_weather_color.dart';

class TodayWearSkeleton extends StatelessWidget {
  const TodayWearSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4093EB), Color(0xFFABDAEF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),

          // 제목 스켈레톤
          Shimmer(
            duration: const Duration(seconds: 2),
            color: Colors.white,
            colorOpacity: 0.3,
            child: Container(
              width: 250,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 추천 옷 섹션 스켈레톤
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 추천 상의 스켈레톤
              Column(
                children: [
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white,
                    colorOpacity: 0.3,
                    child: Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white,
                    colorOpacity: 0.2,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),

              // 추천 아우터 스켈레톤
              Column(
                children: [
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white,
                    colorOpacity: 0.3,
                    child: Container(
                      width: 90,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white,
                    colorOpacity: 0.2,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 그래프 섹션 스켈레톤
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: HowWeatherColor.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 스켈레톤
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        color: Colors.white,
                        colorOpacity: 0.3,
                        child: Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // 범례 스켈레톤
                    Row(
                      children: [
                        // 더움
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Shimmer(
                              duration: const Duration(seconds: 2),
                              color: Colors.white,
                              colorOpacity: 0.3,
                              child: Container(
                                width: 30,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // 적당
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Shimmer(
                              duration: const Duration(seconds: 2),
                              color: Colors.white,
                              colorOpacity: 0.3,
                              child: Container(
                                width: 30,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // 추움
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Shimmer(
                              duration: const Duration(seconds: 2),
                              color: Colors.white,
                              colorOpacity: 0.3,
                              child: Container(
                                width: 30,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

                // 차트 스켈레톤
                const PerceivedTemperatureChartSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PerceivedTemperatureChartSkeleton extends StatelessWidget {
  const PerceivedTemperatureChartSkeleton({super.key});

  static const double columnWidth = 60.0;
  static const double graphHeight = 80.0;
  static const int hourCount = 8; // 예시로 8시간 데이터

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: hourCount * columnWidth,
        child: Stack(
          children: [
            // 그래프 라인 스켈레톤
            Positioned(
              top: 20,
              left: columnWidth / 2,
              right: columnWidth / 2,
              height: graphHeight,
              child: _buildDummyLineChart(count: 8),
            ),

            // 온도와 시간 텍스트 스켈레톤
            Row(
              children: List.generate(hourCount, (index) {
                return SizedBox(
                  width: columnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 온도 스켈레톤
                      Shimmer(
                        duration: const Duration(seconds: 2),
                        color: Colors.white,
                        colorOpacity: 0.3,
                        child: Container(
                          width: 35,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: graphHeight),

                      // 시간 스켈레톤
                      Shimmer(
                        duration: const Duration(seconds: 2),
                        color: Colors.white,
                        colorOpacity: 0.2,
                        child: Container(
                          width: 30,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyLineChart({int count = 8}) {
    // 간단한 상향 그래프 데이터 생성
    final dummySpots = <FlSpot>[];
    for (int i = 0; i < count; i++) {
      // 0부터 시작해서 점진적으로 상승하는 패턴
      double value = 10 + (i * 2.5) + (sin(i * 0.5) * 3); // 약간의 변동을 주면서 상승
      dummySpots.add(FlSpot(i.toDouble(), value));
    }

    return SizedBox(
      height: 50,
      width: count * 60.0 - 60, // 전체 너비 계산
      child: LineChart(
        LineChartData(
          minY: 5,
          maxY: 30,
          minX: 0,
          maxX: count - 1.0,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: dummySpots,
              color: Colors.white.withOpacity(0.7),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white.withOpacity(0.8),
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
