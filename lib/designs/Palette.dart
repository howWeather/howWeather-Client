import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/screens/mypage/clothes/clothes_enroll.dart';
import 'package:client/screens/mypage/clothes/clothes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class Palette extends ConsumerWidget {
  final BuildContext context;
  final WidgetRef ref;
  final String text;
  final String category;
  final int clothId;

  Palette({
    Key? key,
    required this.context,
    required this.ref,
    required this.text,
    required this.category,
    this.clothId = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedThickness = ref.watch(thicknessProvider);
    final selectedColor = ref.watch(colorProvider);

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_22px(text: "의류 $text")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semibold_18px(text: "컬러팔레트"),
          colorList(ref, selectedColor),
          SizedBox(
            height: 8,
          ),
          Semibold_18px(text: "두께"),
          thicknessList(ref, selectedThickness),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
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
                  onTap: () async {
                    if (text == "등록") {
                      final selectedClothType =
                          ref.read(selectedEnrollClothProvider);
                      final clothTypeForCategory = selectedClothType[category];
                      final clothData = {
                        "clothType": clothTypeForCategory,
                        "color": selectedColor,
                        "thickness": selectedThickness,
                      };

                      try {
                        if (category == "uppers") {
                          await ref
                              .read(closetProvider.notifier)
                              .registerClothes(
                            uppers: [clothData],
                            outers: [],
                          );
                        } else if (category == "outers") {
                          await ref
                              .read(closetProvider.notifier)
                              .registerClothes(
                            uppers: [],
                            outers: [clothData],
                          );
                        }

                        context.pop();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('의상이 등록되었습니다.')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('등록 실패: $e')),
                        );
                      }
                    }
                    if (text == "수정") {
                      try {
                        if (category == "uppers") {
                          await ref
                              .read(closetProvider.notifier)
                              .updateUpperCloth(
                                clothId: clothId,
                                color: selectedColor,
                                thickness: selectedThickness,
                              );
                        } else if (category == "outers") {
                          await ref
                              .read(closetProvider.notifier)
                              .updateOuterCloth(
                                clothId: clothId,
                                color: selectedColor,
                                thickness: selectedThickness,
                              );
                        }

                        context.pop();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('의상이 수정되었습니다.')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('등록 실패: $e')),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HowWeatherColor.primary[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Medium_14px(
                        text: text,
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

// 색상 팔레트 리스트
  Widget colorList(WidgetRef ref, int selectedColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
          border: Border.all(color: HowWeatherColor.neutral[100]!, width: 1),
          borderRadius: BorderRadius.circular(12)),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: HowWeatherColor.colorMap.entries.map((entry) {
          final colorId = entry.key;
          final color = entry.value;
          final isSelected = colorId == selectedColor;

          return GestureDetector(
            onTap: () {
              ref.read(colorProvider.notifier).updateColor(colorId);
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border:
                    Border.all(color: HowWeatherColor.neutral[200]!, width: 2),
              ),
              child: isSelected
                  ? SvgPicture.asset(
                      "assets/icons/select.svg",
                      color: selectedColor == 9
                          ? HowWeatherColor.neutral[500]
                          : HowWeatherColor.white,
                      fit: BoxFit.scaleDown,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

// 두께 선택 리스트
  Widget thicknessList(WidgetRef ref, int selectedThickness) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: HowWeatherColor.thicknessMap.entries.map((entry) {
        final thicknessId = entry.key;
        final label = entry.value;
        final isSelected = thicknessId == selectedThickness;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(thicknessProvider.notifier).updateThickness(thicknessId);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4), // 버튼 사이 여백
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? HowWeatherColor.primary[100]
                    : HowWeatherColor.white,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: HowWeatherColor.primary[900]!, width: 2)
                    : Border.all(
                        color: HowWeatherColor.neutral[200]!, width: 2),
              ),
              child: Center(
                child: Medium_14px(text: label),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
