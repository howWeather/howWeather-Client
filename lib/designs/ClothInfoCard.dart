import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/ClothCard.dart';
import 'package:client/designs/Palette.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/screens/mypage/clothes/clothes_view.dart';
import 'package:client/screens/calendar/register/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget ClothInfoCard({
  required BuildContext context,
  required WidgetRef ref,
  required int color,
  required int thicknessLabel,
  required StateProvider<int?> provider,
  required bool havePalette,
  required bool haveDelete,
  required String category,
  required ClothItem selectedItem,
  required int selectedItemId,
  String text = "등록",
}) {
  final selected = ref.watch(provider);
  final isSelected = selected == selectedItemId;

  return InkWell(
    onTap: () {
      ref.read(provider.notifier).state = isSelected ? null : selectedItemId;
      if (category == "uppers") {
        ref.read(registerUpperInfoProvider.notifier).state = selectedItem;
      }
      if (category == "outers") {
        ref.read(registerOuterInfoProvider.notifier).state = selectedItem;
      }
      if (havePalette) {
        ref.read(colorProvider.notifier).state = color;
        ref.read(thicknessProvider.notifier).state = thicknessLabel;
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return WillPopScope(
              onWillPop: () async {
                // 다이얼로그 닫을 때 선택 초기화
                ref.read(provider.notifier).state = null;
                return true;
              },
              child: Palette(
                clothId: selectedItemId,
                context: dialogContext,
                ref: ref,
                text: text,
                category: category,
              ),
            );
          },
        ).then((_) {
          // 다이얼로그 닫힌 후에도 선택 초기화
          ref.read(provider.notifier).state = null;
        });
      }

      if (haveDelete) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return deleteDialog(
              context,
              ref,
              provider,
              color,
              thicknessLabel,
              selectedItemId,
              selectedItem,
              category,
            );
          },
        ).then((_) {
          // 다이얼로그 닫힌 후 선택 초기화
          ref.read(provider.notifier).state = null;
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
          color: isSelected
              ? HowWeatherColor.primary[900]!
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
  StateProvider<int?> provider,
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
          provider: provider,
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
