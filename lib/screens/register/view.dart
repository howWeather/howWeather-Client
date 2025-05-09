import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/screens/todayWeather/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final isAllValidProvider = Provider<bool>((ref) {
  return true;
});
final selectedTemperatureProvider = StateProvider<String?>((ref) => null);
final selectedClothProvider = StateProvider<String?>((ref) => null);
final selectedClothInfoProvider = StateProvider<String?>((ref) => null);

class Register extends ConsumerWidget {
  Register({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherByLocationProvider);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "착장 기록 등록하기"),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            context.pop();
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
                        Semibold_24px(text: "오전"),
                        Bold_40px(text: "16°"),
                      ],
                    ),
                    Spacer(),
                    weatherAsync.when(
                      data: (weather) => Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset("assets/icons/locator.svg"),
                              Semibold_24px(
                                text: weather.name,
                                color: HowWeatherColor.black,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              TemperatureButton("추움", ref),
                              SizedBox(width: 8),
                              TemperatureButton("적당", ref),
                              SizedBox(width: 8),
                              TemperatureButton("더움", ref),
                            ],
                          ),
                        ],
                      ),
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
                  children: [
                    Cloth(context, "상의", ref),
                    Cloth(context, "아우터", ref),
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
      bottomSheet: bottomSheetWidget(context, ref),
    );
  }

  Widget bottomSheetWidget(BuildContext context, ref) {
    final isAllValid = ref.watch(isAllValidProvider);
    return GestureDetector(
      onTap: isAllValid
          ? () {
              context.go('/calendar');
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isAllValid
                ? HowWeatherColor.primary[900]
                : HowWeatherColor.neutral[200],
          ),
          child: Center(
            child: Semibold_24px(
              text: "등록하기",
              color: HowWeatherColor.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget TemperatureButton(String label, WidgetRef ref) {
    final selected = ref.watch(selectedTemperatureProvider);

    // 선택된 상태인지 확인
    final isSelected = selected == label;

    // 라벨에 따라 색상 지정
    Color backgroundColor;
    if (label == "적당") {
      backgroundColor =
          isSelected ? const Color(0xFF15A000) : HowWeatherColor.white;
    } else if (label == "추움") {
      backgroundColor =
          isSelected ? HowWeatherColor.primary[900]! : HowWeatherColor.white;
    } else if (label == "더움") {
      backgroundColor =
          isSelected ? HowWeatherColor.secondary[700]! : HowWeatherColor.white;
    } else {
      backgroundColor = HowWeatherColor.white;
    }

    return GestureDetector(
      onTap: () {
        ref.read(selectedTemperatureProvider.notifier).state = label;
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

  Widget Cloth(BuildContext context, String text, WidgetRef ref) {
    return Column(
      children: [
        Medium_16px(text: text),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ClothModal(context, ref);
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HowWeatherColor.black, width: 1),
            ),
            child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 8),
                child: SvgPicture.asset("assets/icons/search.svg")),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Image.asset("assets/images/windbreak.png"),
        ),
      ],
    );
  }

  Widget ClothModal(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_20px(text: "상의 선택하기")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClothCard("민소매", ref),
          SizedBox(
            height: 12,
          ),
          ClothCard("반소매", ref),
          SizedBox(
            height: 12,
          ),
          ClothCard("긴소매", ref),
          SizedBox(
            height: 12,
          ),
          ClothCard("니트", ref),
          SizedBox(
            height: 12,
          ),
          ClothCard("조끼", ref),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HowWeatherColor.neutral[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Medium_14px(text: "취소")),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/calendar/register');
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HowWeatherColor.primary[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Medium_14px(
                        text: "등록",
                        color: HowWeatherColor.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget ClothCard(text, WidgetRef ref) {
    final selected = ref.watch(selectedClothProvider);

    final isSelected = selected == text;

    return InkWell(
      onTap: () {
        ref.read(selectedClothProvider.notifier).state =
            isSelected ? null : text;
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? HowWeatherColor.primary[50] : HowWeatherColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? HowWeatherColor.neutral[400]!
                  : HowWeatherColor.neutral[200]!,
              width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Medium_14px(text: text),
                isSelected
                    ? SvgPicture.asset("assets/icons/chevron-up.svg")
                    : SvgPicture.asset("assets/icons/chevron-down.svg"),
              ],
            ),
            isSelected
                ? Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        ClothInfoCard(ref, HowWeatherColor.black, "얇음"),
                        ClothInfoCard(ref, HowWeatherColor.black, "보통"),
                        ClothInfoCard(ref, HowWeatherColor.black, "두꺼움"),
                      ],
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget ClothInfoCard(WidgetRef ref, color, thickness) {
    final selected = ref.watch(selectedClothInfoProvider);

    final isSelected = selected == thickness;

    return InkWell(
      onTap: () {
        ref.read(selectedClothInfoProvider.notifier).state =
            isSelected ? null : thickness;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: HowWeatherColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? HowWeatherColor.primary[900]!
                  : HowWeatherColor.white,
              width: 2),
        ),
        child: Row(
          children: [
            Medium_14px(text: "색깔"),
            SizedBox(
              width: 12,
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border:
                    Border.all(color: HowWeatherColor.neutral[200]!, width: 2),
              ),
            ),
            Spacer(),
            Medium_14px(text: "두께"),
            SizedBox(
              width: 12,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: HowWeatherColor.primary[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Medium_14px(
                text: thickness,
                color: HowWeatherColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
