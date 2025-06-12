import 'package:client/api/cloth/cloth_view_model.dart';
import 'package:client/api/record/record_view_model.dart';
import 'package:client/designs/cloth_modal.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:client/screens/calendar/view.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class Register extends ConsumerWidget {
  Register({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherByLocationProvider);
    final weather = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "착장 기록 등록하기"),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            context.pop();
            context.pop();
            // 개선된 방식으로 provider 초기화
            ref.resetClothProviders();
            ref.read(weatherProvider.notifier).state =
                const AsyncValue.loading();
          },
          child: SvgPicture.asset(
            "assets/icons/chevron-left.svg",
            fit: BoxFit.scaleDown,
            height: 20,
            width: 20,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semibold_20px(
                            text: DateFormat('yyyy-MM-dd')
                                .format(ref.read(selectedDayProvider)!)),
                        Row(
                          children: [
                            Semibold_28px(
                                text: ref.read(selectedTimeProvider) != null
                                    ? timeSlotToText(
                                        ref.read(selectedTimeProvider)!)
                                    : ''),
                            SizedBox(
                              width: 8,
                            ),
                            weather.when(
                              data: (temp) => Bold_32px(
                                  text: '${temp.toStringAsFixed(1)}°'),
                              loading: () => SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Medium_14px(text: '위치를 선택해주세요.'),
                              ),
                              error: (e, _) => SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Medium_14px(text: '위치를 선택해주세요.'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    weatherAsync.when(
                      data: (weather) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                await context.push('/calendar/register/search');

                                ref.read(weatherProvider.notifier).state =
                                    const AsyncValue.loading();
                                // 사용자 선택에 따라 온도 조회
                                ref
                                    .read(weatherProvider.notifier)
                                    .fetchTemperature(
                                      city: ref.watch(addressProvider),
                                      timeSlot: ref.read(selectedTimeProvider)!,
                                      date: DateFormat('yyyy-MM-dd').format(
                                          ref.read(selectedDayProvider)!),
                                    );
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/locator.svg",
                                  ),
                                  Semibold_24px(
                                    text: ref
                                                .read(addressProvider.notifier)
                                                .state !=
                                            ""
                                        ? ref.watch(addressProvider)
                                        : '클릭하여 위치 선택',
                                    color: HowWeatherColor.black,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                TemperatureButton(1, ref),
                                SizedBox(width: 8),
                                TemperatureButton(2, ref),
                                SizedBox(width: 8),
                                TemperatureButton(3, ref),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (e, _) => Text('에러: $e'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClothWidget(
                      context,
                      "상의",
                      ref,
                      "uppers",
                    ),
                    _buildClothWidget(
                      context,
                      "아우터",
                      ref,
                      "outers",
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomSheet(context, ref),
    );
  }

  Widget _buildBottomSheet(BuildContext context, WidgetRef ref) {
    final isAllValidProvider = Provider<bool>((ref) {
      final temperature = ref.watch(selectedTemperatureProvider);
      final location = ref.watch(addressProvider);
      final upper = ref.watch(registerUpperProvider);
      final outer = ref.watch(registerOuterProvider);
      return temperature != null &&
          location.isNotEmpty &&
          (upper != null || outer != null);
    });
    final isAllValid = ref.watch(isAllValidProvider);

    return GestureDetector(
      onTap: isAllValid
          ? () {
              if (!TapThrottler.canTap('register')) return;
              _handleSubmit(context, ref);
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isAllValid
                ? HowWeatherColor.primary[900]
                : HowWeatherColor.neutral[200],
          ),
          child: const Center(
            child: Semibold_24px(
              text: "등록하기",
              color: HowWeatherColor.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final upperInfo = ref.read(registerUpperProvider);
    final outerInfo = ref.read(registerOuterProvider);

    // null 체크 먼저 수행
    final timeSlot = ref.read(selectedTimeProvider);
    final feeling = ref.read(selectedTemperatureProvider);
    final selectedDay = ref.read(selectedDayProvider);

    if (timeSlot == null) {
      _showSnackBar(context, '시간을 선택해주세요.', Colors.red);
      return;
    }

    if (feeling == null) {
      _showSnackBar(context, '체감온도를 선택해주세요.', Colors.red);
      return;
    }

    if (selectedDay == null) {
      _showSnackBar(context, '날짜를 선택해주세요.', Colors.red);
      return;
    }

    if (upperInfo == null && outerInfo == null) {
      _showSnackBar(context, '상의 또는 아우터 중 하나 이상을 선택해주세요.', Colors.red);
      return;
    }

    try {
      final upperList = ref.read(registerUpperProvider);
      final outerList = ref.read(registerOuterProvider);

      await ref.read(recordViewModelProvider.notifier).writeRecord(
            timeSlot: timeSlot,
            feeling: feeling,
            date: DateFormat('yyyy-MM-dd').format(selectedDay),
            uppers: upperList.map((e) => e.clothId).toList(),
            outers: outerList.map((e) => e.clothId).toList(),
            city: ref.read(addressProvider),
          );

      await Future.delayed(const Duration(milliseconds: 1500));
      ref.resetClothProviders();
      ref.read(weatherProvider.notifier).state = const AsyncValue.loading();
      // context.go('/calendar');
      context.pop();
      context.pop();

      _showSnackBar(context, '기록이 성공적으로 저장되었어요!', Colors.green);
    } catch (e) {
      _showSnackBar(context, '$e', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget TemperatureButton(int value, WidgetRef ref) {
    final selected = ref.watch(selectedTemperatureProvider);
    String label;
    Color backgroundColor;

    switch (value) {
      case 1:
        label = "추움";
        backgroundColor = selected == 1
            ? HowWeatherColor.primary[900]!
            : HowWeatherColor.white;
        break;
      case 2:
        label = "적당";
        backgroundColor = selected == 2
            ? HowWeatherColor.secondary[400]!
            : HowWeatherColor.white;
        break;
      case 3:
        label = "더움";
        backgroundColor = selected == 3
            ? HowWeatherColor.secondary[700]!
            : HowWeatherColor.white;
        break;
      default:
        label = "";
        backgroundColor = HowWeatherColor.white;
    }

    final isSelected = selected == value;

    return GestureDetector(
      onTap: () {
        ref.read(selectedTemperatureProvider.notifier).state = value;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: HowWeatherColor.neutral[200]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Medium_14px(
            text: label,
            color: isSelected ? HowWeatherColor.white : HowWeatherColor.black,
          ),
        ),
      ),
    );
  }

  Widget _buildClothWidget(
    BuildContext context,
    String text,
    WidgetRef ref,
    String category,
  ) {
    // 선택된 아이템들 가져오기
    final selectedItems = category == "uppers"
        ? ref.watch(registerUpperProvider)
        : ref.watch(registerOuterProvider);

    return Column(
      children: [
        Medium_16px(text: text),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ClothModal(
                  text: text,
                  category: category,
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HowWeatherColor.black, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: selectedItems.isEmpty
                      ? Medium_16px(text: "$text 선택")
                      : Medium_16px(text: "${selectedItems.length}개 선택됨"),
                ),
                SvgPicture.asset("assets/icons/search.svg"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: selectedItems.isEmpty
              ? Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: HowWeatherColor.neutral[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HowWeatherColor.neutral[200]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: HowWeatherColor.neutral[400],
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Medium_14px(
                          text: "$text 선택",
                          color: HowWeatherColor.neutral[400],
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    final realColor = HowWeatherColor.colorMap[item.color] ??
                        Colors.transparent;
                    final matrix =
                        HowWeatherColor.createColorMatrixFromColor(realColor);

                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: HowWeatherColor.neutral[200]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FutureBuilder<String>(
                              future: category == "uppers"
                                  ? ref
                                      .read(clothViewModelProvider.notifier)
                                      .getUpperClothImage(item.clothType)
                                  : ref
                                      .read(clothViewModelProvider.notifier)
                                      .getOuterClothImage(item.clothType),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Icon(Icons.error));
                                } else if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty &&
                                    Uri.tryParse(snapshot.data!)
                                            ?.hasAbsolutePath ==
                                        true) {
                                  return ColorFiltered(
                                    colorFilter: ColorFilter.matrix(matrix),
                                    child: Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ),
                        // 삭제 버튼
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              if (category == "uppers") {
                                final currentList =
                                    ref.read(registerUpperProvider);
                                ref.read(registerUpperProvider.notifier).state =
                                    currentList
                                        .where((i) => i.clothId != item.clothId)
                                        .toList();
                              } else {
                                final currentList =
                                    ref.read(registerOuterProvider);
                                ref.read(registerOuterProvider.notifier).state =
                                    currentList
                                        .where((i) => i.clothId != item.clothId)
                                        .toList();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: HowWeatherColor.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: HowWeatherColor.neutral[600],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
