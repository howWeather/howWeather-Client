import 'package:client/designs/cloth_info_card.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClothCard extends ConsumerWidget {
  final ClothItem item;
  final List<ClothItem> allItems;
  final String category;
  final int initColor;
  final int initThickness;
  final bool havePalette;
  final bool haveDelete;
  final String text;

  const ClothCard({
    super.key,
    required this.item,
    required this.allItems,
    required this.category,
    required this.initColor,
    required this.initThickness,
    this.havePalette = true,
    this.haveDelete = false,
    this.text = "등록",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // category에 따라 올바른 provider 사용
    final selected = ref.watch(selectedClothProvider(category));
    final isSelected = selected == item.clothId;

    final sameTypeItems =
        allItems.where((i) => i.clothType == item.clothType).toList();

    return InkWell(
      onTap: () {
        final currentSelected = ref.read(selectedClothProvider(category));
        ref.read(selectedClothProvider(category).notifier).state =
            currentSelected == item.clothId ? null : item.clothId;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: HowWeatherColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? HowWeatherColor.primary[400]!
                : HowWeatherColor.neutral[200]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Medium_14px(
                  text: clothTypeToKorean(category, item.clothType),
                ),
                SvgPicture.asset(
                  isSelected
                      ? "assets/icons/chevron-up.svg"
                      : "assets/icons/chevron-down.svg",
                ),
              ],
            ),
            if (isSelected)
              ...sameTypeItems.map((i) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClothInfoCard(
                      text: text,
                      context: context,
                      ref: ref,
                      color: i.color,
                      thicknessLabel: i.thickness,
                      selectedItemId: i.clothId,
                      selectedItem: i,
                      havePalette: havePalette,
                      haveDelete: haveDelete,
                      category: category,
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

String clothTypeToKorean(String category, int type) {
  const upperMap = {
    1: "민소매",
    2: "반소매",
    3: "긴소매",
    4: "니트",
    5: "조끼",
    6: "셔츠",
    7: "원피스",
    8: "후드티",
    9: "맨투맨",
  };

  const outerMap = {
    1: "가디건",
    2: "트렌치코트",
    3: "블레이저",
    4: "트위드 자켓",
    5: "코듀로이 자켓",
    6: "청자켓",
    7: "가죽자켓",
    8: "항공점퍼",
    9: "야구잠바",
    10: "후리스",
    11: "후드집업",
    12: "져지",
    13: "바람막이",
    14: "무스탕",
    15: "코트",
    16: "경량패딩",
    17: "숏패딩",
    18: "롱패딩",
  };

  if (category == 'uppers') {
    return upperMap[type] ?? "";
  } else if (category == 'outers') {
    return outerMap[type] ?? "";
  } else {
    return "";
  }
}
