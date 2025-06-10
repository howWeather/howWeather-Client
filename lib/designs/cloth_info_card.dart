import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/Palette.dart';
import 'package:client/designs/cloth_card.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget ClothInfoCard({
  required BuildContext context,
  required WidgetRef ref,
  required int color,
  required int thicknessLabel,
  required bool havePalette,
  required bool haveDelete,
  required String category,
  required ClothItem selectedItem,
  required int selectedItemId,
  String text = "등록",
}) {
  final selectedInfo = ref.watch(selectedClothInfoProvider(category));

  return InkWell(
    onTap: () {
      ref.read(selectedClothInfoProvider(category).notifier).state =
          selectedItem;
      if (havePalette) {
        ref.read(colorProvider.notifier).state = color;
        ref.read(thicknessProvider.notifier).state = thicknessLabel;
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return Palette(
              clothId: selectedItemId,
              text: text,
              category: category,
              initialColor: color,
              initialThickness: thicknessLabel,
            );
          },
        ).then((_) {
          // 다이얼로그 닫힌 후에도 선택 초기화
          ref.resetClothInfoProviders();
          print('등록 창 닫기');
        });
      }

      if (haveDelete) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return deleteDialog(
              context,
              ref,
              color,
              thicknessLabel,
              selectedItemId,
              selectedItem,
              category,
            );
          },
        ).then((_) {
          // 다이얼로그 닫힌 후 선택 초기화
          ref.resetClothInfoProviders();
        });
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: HowWeatherColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selectedInfo == selectedItem
              ? HowWeatherColor.neutral[700]!
              : HowWeatherColor.neutral[100]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Medium_14px(text: "색깔"),
          const SizedBox(width: 12),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: HowWeatherColor.colorMap[color],
              shape: BoxShape.circle,
              border: Border.all(
                color: HowWeatherColor.neutral[200]!,
                width: 2,
              ),
            ),
          ),
          const Spacer(),
          Medium_14px(text: "두께"),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: HowWeatherColor.primary[600],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Medium_14px(
              text: HowWeatherColor.thicknessMap[thicknessLabel]!,
              color: HowWeatherColor.white,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget deleteDialog(
  BuildContext context,
  WidgetRef ref,
  int color,
  int thickness,
  selectedItemId,
  selectedItem,
  String category,
) {
  return AlertDialog(
    backgroundColor: HowWeatherColor.white,
    title: Center(child: Semibold_20px(text: "의류 삭제")),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Medium_18px(text: "의류를 삭제하시겠습니까?"),
        SizedBox(
          height: 12,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Medium_14px(text: clothTypeToKorean(category, selectedItemId)),
        ),
        SizedBox(
          height: 8,
        ),
        ClothInfoCard(
          context: context,
          ref: ref,
          color: color,
          thicknessLabel: thickness,
          havePalette: false,
          haveDelete: false,
          selectedItemId: selectedItemId,
          selectedItem: selectedItem,
          category: category,
        ),
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
                  if (category == 'uppers') {
                    ref
                        .read(closetProvider.notifier)
                        .deleteUpperCloth(clothId: selectedItemId);
                  }
                  if (category == 'outers') {
                    ref
                        .read(closetProvider.notifier)
                        .deleteOuterCloth(clothId: selectedItemId);
                  }
                  context.pop();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HowWeatherColor.secondary[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Medium_14px(
                      text: "삭제",
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
