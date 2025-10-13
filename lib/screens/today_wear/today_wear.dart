import 'dart:math';

import 'package:client/api/cloth/cloth_view_model.dart';
import 'package:client/api/model/model_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/toast.dart';
import 'package:client/model/weather.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:client/providers/location_provider.dart';
import 'package:client/screens/home_widget/home_widget.dart';
import 'package:client/screens/skeleton/wear_skeleton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class TodayWear extends ConsumerStatefulWidget {
  const TodayWear({super.key});

  @override
  ConsumerState<TodayWear> createState() => _TodayWearState();
}

class _TodayWearState extends ConsumerState<TodayWear> {
  int currentUpperIndex = 0; // 현재 보고 있는 상의 인덱스
  int currentOuterIndex = 0; // 현재 보고 있는 아우터 인덱스

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // 초기 데이터 로딩
  Future<void> _initializeData() async {
    // 사용자 위치 조회
    await ref.read(locationViewModelProvider.notifier).fetchUserLocation();
    // 추천 데이터 조회
    await ref.read(modelViewModelProvider.notifier).fetchRecommendation();
  }

  // 상의 이전 항목으로 이동
  void previousUpper(int totalCount) {
    setState(() {
      currentUpperIndex = (currentUpperIndex - 1 + totalCount) % totalCount;
    });
  }

  // 상의 다음 항목으로 이동
  void nextUpper(int totalCount) {
    setState(() {
      currentUpperIndex = (currentUpperIndex + 1) % totalCount;
    });
  }

  // 아우터 이전 항목으로 이동
  void previousOuter(int totalCount) {
    setState(() {
      currentOuterIndex = (currentOuterIndex - 1 + totalCount) % totalCount;
    });
  }

  // 아우터 다음 항목으로 이동
  void nextOuter(int totalCount) {
    setState(() {
      currentOuterIndex = (currentOuterIndex + 1) % totalCount;
    });
  }

  // 모든 추천에서 상의 타입들을 수집
  List<int> getAllUpperTypes(List<dynamic> recommendations) {
    Set<int> upperTypes = {};
    for (var recommendation in recommendations) {
      upperTypes.addAll(List<int>.from(recommendation.uppersTypeList));
    }
    return upperTypes.toList();
  }

  // 모든 추천에서 아우터 타입들을 수집
  List<int> getAllOuterTypes(List<dynamic> recommendations) {
    Set<int> outerTypes = {};
    for (var recommendation in recommendations) {
      outerTypes.addAll(List<int>.from(recommendation.outersTypeList));
    }
    return outerTypes.toList();
  }

  @override
  Widget build(BuildContext context) {
    final hourlyWeather = ref.watch(hourlyWeatherProvider);
    final modelState = ref.watch(modelViewModelProvider);
    final currentUserLocation = ref.watch(userLocationProvider);

    return hourlyWeather.when(
      data: (hourlyData) {
        return RefreshIndicator(
          onRefresh: () async {
            await _initializeData();
          },
          color: HowWeatherColor.primary[900],
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4093EB), const Color(0xFFABDAEF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Semibold_24px(
                        text: "오늘 날씨에 추천하는 의류예요!",
                        color: HowWeatherColor.white,
                      ),
                      SizedBox(height: 20),
                      modelState.when(
                        loading: () => Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) {
                          print(e);
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Center(
                              child: Semibold_18px(
                                text: "데이터를 불러오는 중 오류가 발생했어요.",
                                color: HowWeatherColor.white,
                              ),
                            ),
                          );
                        },
                        data: (recommendations) {
                          if (recommendations.isEmpty) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: HowWeatherColor.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      width: 40,
                                      'assets/icons/closet-off2.svg',
                                      color: HowWeatherColor.white,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Medium_16px(
                                      text:
                                          "추천 가능한 의류가 없어요...😦\n[마이페이지-나의 옷장]에서 새로운 의류를 추가해 보세요!",
                                      color: HowWeatherColor.white,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // 모든 추천에서 상의와 아우터 타입들을 수집
                          final allUpperTypes =
                              getAllUpperTypes(recommendations);
                          final allOuterTypes =
                              getAllOuterTypes(recommendations);

                          // 인덱스 초기화 (타입이 변경되었을 때)
                          if (currentUpperIndex >= allUpperTypes.length) {
                            currentUpperIndex = 0;
                          }
                          if (currentOuterIndex >= allOuterTypes.length) {
                            currentOuterIndex = 0;
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 상의 섹션
                              if (allUpperTypes.isNotEmpty)
                                Expanded(
                                  child: _buildClothSection(
                                    title: "추천 상의류",
                                    clothTypes: allUpperTypes,
                                    currentIndex: currentUpperIndex,
                                    onPrevious: () =>
                                        previousUpper(allUpperTypes.length),
                                    onNext: () =>
                                        nextUpper(allUpperTypes.length),
                                    isUpper: true,
                                  ),
                                ),
                              // 아우터 섹션
                              if (allOuterTypes.isNotEmpty) ...[
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildClothSection(
                                    title: "추천 아우터류",
                                    clothTypes: allOuterTypes,
                                    currentIndex: currentOuterIndex,
                                    onPrevious: () =>
                                        previousOuter(allOuterTypes.length),
                                    onNext: () =>
                                        nextOuter(allOuterTypes.length),
                                    isUpper: false,
                                  ),
                                ),
                              ]
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 40),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: HowWeatherColor.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Medium_16px(
                                  text: '체감별 날씨 그래프',
                                  color: HowWeatherColor.white,
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
                                SizedBox(width: 4),
                                Medium_14px(
                                  text: "더움",
                                  color: HowWeatherColor.white,
                                ),
                                SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: HowWeatherColor.secondary[500],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Medium_14px(
                                  text: "적당",
                                  color: HowWeatherColor.white,
                                ),
                                SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: HowWeatherColor.primary[800],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Medium_14px(
                                  text: "추움",
                                  color: HowWeatherColor.white,
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(
                                height: 1,
                                color: HowWeatherColor.white.withOpacity(0.5),
                              ),
                            ),
                            PerceivedTemperatureChart(hourlyData: hourlyData),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                    final selectedLocation =
                                        await context.push('/location-search');
                                    if (selectedLocation != null &&
                                        selectedLocation is String) {
                                      try {
                                        await ref
                                            .read(locationViewModelProvider
                                                .notifier)
                                            .updateUserLocation(
                                                selectedLocation);
                                        if (context.mounted) {
                                          HowWeatherToast.show(
                                              context,
                                              '위치가 $selectedLocation으로 설정됐어요.',
                                              false);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          HowWeatherToast.show(
                                              context, '${e.toString()}', true);
                                        }
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: HowWeatherColor.white,
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            'assets/icons/locator.svg'),
                                        SizedBox(width: 4),
                                        Semibold_16px(
                                          text: currentUserLocation ??
                                              '서울특별시 용산구',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(
                                height: 1,
                                color: HowWeatherColor.white.withOpacity(0.5),
                              ),
                            ),
                            Medium_14px(
                              text: '''- 기준 지역의 예보 데이터를 이용하여 의상을 추천합니다.
- 초기 설정은 서울특별시 용산구입니다.''',
                              color: HowWeatherColor.white,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => TodayWearSkeleton(),
      error: (e, st) => Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF4093EB), const Color(0xFFABDAEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            '에러 발생: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // 옷 섹션 빌더 (상의 또는 아우터)
  Widget _buildClothSection({
    required String title,
    required List<int> clothTypes,
    required int currentIndex,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
    required bool isUpper,
  }) {
    if (clothTypes.isEmpty) return SizedBox();

    final clothImageAsync = isUpper
        ? ref.watch(upperClothImageProvider(clothTypes[currentIndex]))
        : ref.watch(outerClothImageProvider(clothTypes[currentIndex]));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 제목과 인디케이터
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semibold_20px(
              text: title,
              color: HowWeatherColor.white,
            ),
            if (clothTypes.length > 1) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: HowWeatherColor.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${currentIndex + 1}/${clothTypes.length}',
                  style: TextStyle(
                    color: HowWeatherColor.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),

        // 이미지와 화살표
        Stack(
          alignment: Alignment.center,
          children: [
            // 이미지
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              child: clothImageAsync.when(
                data: (url) => Image.network(
                  url,
                  fit: BoxFit.fill,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Icon(Icons.error),
              ),
            ),

            // 화살표 (여러 옵션이 있을 때만 표시)
            if (clothTypes.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽 화살표
                  GestureDetector(
                    onTap: onPrevious,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HowWeatherColor.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: HowWeatherColor.white,
                        size: 16,
                      ),
                    ),
                  ),
                  // 오른쪽 화살표
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HowWeatherColor.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: HowWeatherColor.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
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
    final modelState = ref.watch(modelViewModelProvider);

    return modelState.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('에러 발생: $e'),
      data: (recommendations) {
        if (recommendations.isEmpty || recommendations.length < 2) {
          return Text(
            '추천 데이터가 부족해요.',
            style: TextStyle(color: HowWeatherColor.white),
          );
        }

        // feelingList에서 온도와 체감 정도를 가져옵니다
        final allFeelingList = [
          ...recommendations[0].feelingList,
          ...recommendations[1].feelingList,
        ];

        // 중복 제거 및 시간 순 정렬 (시간을 기준으로 유니크하게)
        final Map<int, dynamic> uniqueFeelingsMap = {};
        for (var feeling in allFeelingList) {
          uniqueFeelingsMap[feeling.time] = feeling;
        }
        final uniqueFeelings = uniqueFeelingsMap.values.toList()
          ..sort((a, b) => a.time.compareTo(b.time));

        if (uniqueFeelings.isEmpty) {
          return Text(
            '추천 데이터가 없어요.',
            style: TextStyle(color: HowWeatherColor.white),
          );
        }

        // 최소/최대 온도 계산 (추천 데이터 기준)
        final temperatures =
            uniqueFeelings.map((e) => e.temperature as double).toList();
        final minTemp = temperatures.reduce(min) - 5;
        final maxTemp = temperatures.reduce(max) + 5;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: uniqueFeelings.length * columnWidth,
            child: Stack(
              children: [
                // 📌 그래프
                Positioned(
                  top: 20,
                  left: columnWidth / 2,
                  right: columnWidth / 2,
                  height: graphHeight,
                  child: LineChart(
                    LineChartData(
                      minY: minTemp,
                      maxY: maxTemp,
                      minX: 0,
                      maxX: (uniqueFeelings.length - 1) * columnWidth,
                      titlesData: FlTitlesData(show: false),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: uniqueFeelings.asMap().entries.map((entry) {
                            final index = entry.key;
                            final feeling = entry.value;
                            return FlSpot(
                                index * columnWidth, feeling.temperature);
                          }).toList(),
                          color: Colors.white,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              if (index >= uniqueFeelings.length) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: HowWeatherColor.neutral[200]!,
                                  strokeColor: Colors.transparent,
                                );
                              }

                              final colorIndex = uniqueFeelings[index].feeling;

                              late Color color;
                              if (colorIndex == 3) {
                                color = HowWeatherColor.secondary[800]!; // 더움
                              } else if (colorIndex == 2) {
                                color = HowWeatherColor.secondary[500]!; // 적당
                              } else if (colorIndex == 1) {
                                color = HowWeatherColor.primary[800]!; // 추움
                              } else {
                                color = HowWeatherColor.neutral[200]!;
                              }

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
                  children: uniqueFeelings.map((feeling) {
                    return SizedBox(
                      width: columnWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Medium_16px(
                            text: '${feeling.temperature.toStringAsFixed(0)}°',
                            color: HowWeatherColor.white,
                          ),
                          const SizedBox(height: graphHeight),
                          Medium_14px(
                            text: '${feeling.time}시',
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
      },
    );
  }
}
