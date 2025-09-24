// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';

class CalendarSkeleton extends StatelessWidget {
  const CalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: HowWeatherColor.white,
        surfaceTintColor: Colors.transparent,
        title: Bold_22px(
          text: "기록 달력",
          color: HowWeatherColor.black,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 34),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: _buildCalendarSkeleton(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Divider(
                      height: 1,
                      color: HowWeatherColor.neutral[200],
                    ),
                  ),
                  _buildDailyHistorySkeleton(context),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSkeleton() {
    return Column(
      children: [
        // 달력 헤더 (년/월)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          color: HowWeatherColor.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer(
                duration: Duration(milliseconds: 1500),
                color: HowWeatherColor.neutral[300]!,
                colorOpacity: 0.3,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: HowWeatherColor.neutral[200],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Shimmer(
                duration: Duration(milliseconds: 1500),
                color: HowWeatherColor.neutral[300]!,
                colorOpacity: 0.3,
                child: Container(
                  width: 120,
                  height: 32,
                  decoration: BoxDecoration(
                    color: HowWeatherColor.neutral[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Shimmer(
                duration: Duration(milliseconds: 1500),
                color: HowWeatherColor.neutral[300]!,
                colorOpacity: 0.3,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: HowWeatherColor.neutral[200],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        // 달력 본체
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: HowWeatherColor.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // 요일 헤더
              _buildWeekdayHeader(),
              SizedBox(height: 10),
              // 달력 날짜들
              Container(
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 20,
                      height: 18,
                      color: HowWeatherColor.white,
                    ),
                    Container(
                      width: 20,
                      height: 18,
                      color: HowWeatherColor.white,
                    ),
                    Container(
                      width: 20,
                      height: 18,
                      color: HowWeatherColor.white,
                    ),
                    Container(
                      width: 20,
                      height: 18,
                      color: HowWeatherColor.white,
                    ),
                    Container(
                      width: 20,
                      height: 18,
                      color: HowWeatherColor.white,
                    ),
                    _buildDaySkeleton(0, 1),
                    _buildDaySkeleton(5, 4),
                  ],
                ),
              ),
              _buildCalendarDays(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Container(
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          return Expanded(
            child: Center(
              child: Shimmer(
                duration: Duration(milliseconds: 1500),
                color: HowWeatherColor.neutral[300]!,
                colorOpacity: 0.3,
                child: Container(
                  width: 20,
                  height: 18,
                  decoration: BoxDecoration(
                    color: HowWeatherColor.neutral[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarDays() {
    return Column(
      children: List.generate(4, (weekIndex) {
        return Container(
          height: 55,
          child: Row(
            children: List.generate(7, (dayIndex) {
              return Expanded(
                child: Center(
                  child: _buildDaySkeleton(weekIndex, dayIndex),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDaySkeleton(int weekIndex, int dayIndex) {
    // 일부 날짜에는 마커나 특별 스타일 추가
    bool hasMarker = (weekIndex + dayIndex) % 7 == 2;
    bool isToday = weekIndex == 2 && dayIndex == 3;
    bool isSelected = weekIndex == 1 && dayIndex == 5;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 선택된 날짜 배경
        // if (isSelected)
        //   Positioned(
        //     top: -5,
        //     child: Shimmer(
        //       duration: Duration(milliseconds: 1500),
        //       color: HowWeatherColor.secondary[300]!,
        //       colorOpacity: 0.3,
        //       child: Container(
        //         width: 35,
        //         height: 35,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: HowWeatherColor.secondary[200],
        //         ),
        //       ),
        //     ),
        //   ),
        // // 마커 (기록 있는 날)
        // if (hasMarker)
        //   Positioned(
        //     top: -7,
        //     child: Shimmer(
        //       duration: Duration(milliseconds: 1500),
        //       color: HowWeatherColor.primary[200]!,
        //       colorOpacity: 0.3,
        //       child: Container(
        //         width: 39,
        //         height: 39,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           border: Border.all(
        //             color: HowWeatherColor.primary[200]!,
        //             width: 3,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // 날짜 숫자
        Align(
          alignment: Alignment.topCenter,
          child: Shimmer(
            duration: Duration(milliseconds: 1500),
            color: HowWeatherColor.neutral[300]!,
            colorOpacity: 0.3,
            child: Container(
              width: 20,
              height: 18,
              decoration: BoxDecoration(
                color: HowWeatherColor.neutral[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // 오늘 표시
        // if (isToday)
        //   Positioned(
        //     top: 28,
        //     child: Shimmer(
        //       duration: Duration(milliseconds: 1500),
        //       color: HowWeatherColor.secondary[300]!,
        //       colorOpacity: 0.3,
        //       child: Container(
        //         width: 30,
        //         height: 14,
        //         decoration: BoxDecoration(
        //           color: HowWeatherColor.secondary[200],
        //           borderRadius: BorderRadius.circular(4),
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildDailyHistorySkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 제목
        Shimmer(
          duration: Duration(milliseconds: 1500),
          color: HowWeatherColor.neutral[300]!,
          colorOpacity: 0.3,
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: HowWeatherColor.neutral[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 20),
        // 기록 리스트
        Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 시간대, 온도, 느낌
                  Row(
                    children: [
                      Shimmer(
                        duration: Duration(milliseconds: 1500),
                        color: HowWeatherColor.neutral[300]!,
                        colorOpacity: 0.3,
                        child: Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: HowWeatherColor.neutral[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Shimmer(
                        duration: Duration(milliseconds: 1500),
                        color: HowWeatherColor.neutral[300]!,
                        colorOpacity: 0.3,
                        child: Container(
                          width: 35,
                          height: 20,
                          decoration: BoxDecoration(
                            color: HowWeatherColor.neutral[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Shimmer(
                        duration: Duration(milliseconds: 1500),
                        color: HowWeatherColor.neutral[300]!,
                        colorOpacity: 0.3,
                        child: Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: HowWeatherColor.neutral[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 옷 이미지들
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(3, (imgIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Shimmer(
                              duration: Duration(milliseconds: 1500),
                              color: HowWeatherColor.neutral[300]!,
                              colorOpacity: 0.3,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: HowWeatherColor.neutral[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// 로딩 상태에서 사용할 수 있는 간단한 스켈레톤 컴포넌트들
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(milliseconds: 1500),
      color: highlightColor ?? HowWeatherColor.neutral[300]!,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor ?? HowWeatherColor.neutral[200],
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double diameter;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerCircle({
    Key? key,
    required this.diameter,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(milliseconds: 1500),
      color: highlightColor ?? HowWeatherColor.neutral[300]!,
      colorOpacity: 0.3,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: baseColor ?? HowWeatherColor.neutral[200],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerText({
    Key? key,
    required this.width,
    this.height = 16,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(milliseconds: 1500),
      color: highlightColor ?? HowWeatherColor.neutral[300]!,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor ?? HowWeatherColor.neutral[200],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
