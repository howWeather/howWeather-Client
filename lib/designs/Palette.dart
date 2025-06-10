import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class Palette extends ConsumerStatefulWidget {
  final String text;
  final String category;
  final int clothId;
  final int initialColor;
  final int initialThickness;

  Palette({
    Key? key,
    required this.text,
    required this.category,
    this.clothId = 0,
    required this.initialColor,
    required this.initialThickness,
  }) : super(key: key);

  @override
  ConsumerState<Palette> createState() => _PaletteState();
}

class _PaletteState extends ConsumerState<Palette> {
  @override
  void initState() {
    super.initState();
    // 초기 상태 세팅
    ref.read(colorProvider.notifier).state = widget.initialColor;
    ref.read(thicknessProvider.notifier).state = widget.initialThickness;
  }

  @override
  Widget build(BuildContext context) {
    final selectedThickness = ref.watch(thicknessProvider);
    final selectedColor = ref.watch(colorProvider);

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_22px(text: "의류 ${widget.text}")),
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
                    if (widget.text == "등록") {
                      final selectedClothType =
                          ref.read(selectedEnrollClothProvider);
                      print('selectedClothType: $selectedClothType');
                      final clothTypeForCategory =
                          selectedClothType[widget.category];
                      final clothData = {
                        "clothType": clothTypeForCategory,
                        "color": selectedColor,
                        "thickness": selectedThickness,
                      };

                      try {
                        if (widget.category == "uppers") {
                          await ref
                              .read(closetProvider.notifier)
                              .registerClothes(
                            uppers: [clothData],
                            outers: [],
                          );
                        } else if (widget.category == "outers") {
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
                    if (widget.text == "수정") {
                      try {
                        if (widget.category == "uppers") {
                          await ref
                              .read(closetProvider.notifier)
                              .updateUpperCloth(
                                clothId: widget.clothId,
                                color: selectedColor,
                                thickness: selectedThickness,
                              );
                        } else if (widget.category == "outers") {
                          await ref
                              .read(closetProvider.notifier)
                              .updateOuterCloth(
                                clothId: widget.clothId,
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
                        text: widget.text,
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
              ref.read(colorProvider.notifier).state = colorId;
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
              ref.read(thicknessProvider.notifier).state = thicknessId;
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
