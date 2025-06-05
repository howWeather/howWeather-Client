import 'dart:math';
import 'package:client/designs/how_weather_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WeatherSkeletonScreen extends StatelessWidget {
  const WeatherSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dummyHourly = 8;
    const dummyDaily = 6;

    return Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(seconds: 1),
      color: Colors.white,
      colorOpacity: 0.2,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Column(
        children: [
          const SizedBox(height: 50),
          // 상단 날씨 요약
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(width: 160, height: 20),
                  const SizedBox(height: 8),
                  _skeletonBox(width: 80, height: 80),
                  const SizedBox(height: 8),
                  _skeletonBox(width: 100, height: 20),
                ],
              ),
              _skeletonCircle(size: 80),
            ],
          ),
          const SizedBox(height: 40),

          // 시간별 날씨
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HowWeatherColor.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 100, height: 20),
                const SizedBox(height: 10),
                Divider(color: Colors.white.withOpacity(0.5), height: 1),
                const SizedBox(height: 10),
                _buildHourlySkeleton(dummyHourly),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 주간 날씨 예보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HowWeatherColor.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 100, height: 20),
                const SizedBox(height: 10),
                Divider(color: Colors.white.withOpacity(0.5), height: 1),
                const SizedBox(height: 10),
                _buildDailySkeleton(dummyDaily),
              ],
            ),
          ),

          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _skeletonBox({double width = 100, double height = 20}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: HowWeatherColor.neutral[100],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _skeletonCircle({double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HowWeatherColor.neutral[100],
        borderRadius: BorderRadius.circular(30),
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
      height: 80,
      width: count * 60.0 - 60, // 전체 너비 계산
      child: LineChart(
        LineChartData(
          minY: 8,
          maxY: 25,
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

  Widget _buildHourlySkeleton(int count) {
    return SizedBox(
      height: 220,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: count * 60.0,
          child: Stack(
            children: [
              // 시간, 아이콘, 온도, 습도 표시
              Positioned.fill(
                child: Row(
                  children: List.generate(count, (index) {
                    return SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _skeletonBox(width: 25, height: 14),
                          const SizedBox(height: 4),
                          _skeletonCircle(size: 30),
                          const SizedBox(height: 4),
                          _skeletonBox(width: 28, height: 16),
                          const SizedBox(height: 100), // 그래프 공간
                          _skeletonBox(width: 30, height: 14),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              // 그래프 배치
              Positioned(
                top: 84,
                left: 30, // 첫 번째 열의 중앙
                right: 30, // 마지막 열의 중앙
                height: 80,
                child: _buildDummyLineChart(count: count),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySkeleton(int count) {
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                child: _skeletonBox(width: 60, height: 14),
              ),
              const Spacer(),
              SizedBox(
                width: 40,
                child: Center(child: _skeletonBox(width: 40, height: 14)),
              ),
              SizedBox(
                width: 50,
                child: Center(child: _skeletonCircle(size: 30)),
              ),
              SizedBox(
                width: 50,
                child: Center(child: _skeletonBox(width: 30, height: 14)),
              ),
              SizedBox(
                width: 50,
                child: Center(child: _skeletonBox(width: 30, height: 14)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
