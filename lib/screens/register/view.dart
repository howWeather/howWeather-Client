import 'package:client/api/record/record_view_model.dart';
import 'package:client/designs/ClothCard.dart';
import 'package:client/designs/ClothModal.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/screens/calendar/view.dart';
import 'package:client/screens/todayWeather/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final isAllValidProvider = Provider<bool>((ref) {
  return true;
});
final selectedTemperatureProvider = StateProvider<int?>((ref) => null);
final selectedClothProvider = StateProvider<int?>((ref) => null);
final selectedClothInfoProvider = StateProvider<int?>((ref) => null);
final registerUpperInfoProvider = StateProvider<ClothItem?>((ref) => null);
final registerOuterInfoProvider = StateProvider<ClothItem?>((ref) => null);
final addressProvider = StateProvider<String>((ref) => "");

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
            ref.read(selectedTemperatureProvider.notifier).state = null;
            ref.read(addressProvider.notifier).state = "";
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
                            Semibold_28px(text: "오전"),
                            SizedBox(
                              width: 8,
                            ),
                            Bold_32px(text: "16°"),
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
                              onTap: () {
                                context.push('/calendar/register/search');
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset("assets/icons/locator.svg"),
                                  Semibold_24px(
                                    text: ref.watch(addressProvider),
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
                  children: [
                    Cloth(context, "상의", ref, "uppers",
                        ref.watch(registerUpperInfoProvider)?.clothType ?? 0),
                    Cloth(context, "아우터", ref, "outers",
                        ref.watch(registerOuterInfoProvider)?.clothType ?? 0),
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
          ? () async {
              try {
                await ref.read(recordViewModelProvider.notifier).writeRecord(
                      timeSlot: ref.read(selectedTimeProvider),
                      feeling: ref.read(selectedTemperatureProvider),
                      date: DateFormat('yyyy-MM-dd')
                          .format(ref.read(selectedDayProvider)),
                      uppers: List<int>.from(
                          [ref.read(registerUpperInfoProvider)!.clothId]),
                      outers: List<int>.from(
                          [ref.read(registerOuterInfoProvider)!.clothId]),
                      city: ref.read(addressProvider),
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('기록이 성공적으로 저장되었어요!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                await Future.delayed(const Duration(milliseconds: 1500));
                ref.read(addressProvider.notifier).state = "";
                context.go('/calendar');
              } catch (e) {
                // ❌ 실패 스낵바
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
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

  Widget Cloth(BuildContext context, String text, WidgetRef ref,
      String category, int type) {
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
                return ClothModal(
                    context: context,
                    ref: ref,
                    text: text,
                    category: category,
                    provider: selectedClothProvider,
                    infoProvider: selectedClothInfoProvider);
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HowWeatherColor.black, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Medium_16px(text: clothTypeToKorean(category, type)),
                SvgPicture.asset("assets/icons/search.svg"),
              ],
            ),
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
}
