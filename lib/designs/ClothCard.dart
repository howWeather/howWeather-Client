import 'package:client/designs/ClothInfoCard.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget ClothCard(
    ClothItem item,
    WidgetRef ref,
    StateProvider<int?> selectedProvider,
    StateProvider<int?> infoProvider,
    String category) {
  final selected = ref.watch(selectedProvider);
  final isSelected = selected == item.clothId;

  return InkWell(
    onTap: () {
      ref.read(selectedProvider.notifier).state =
          isSelected ? null : item.clothId;
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? HowWeatherColor.primary[50] : HowWeatherColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? HowWeatherColor.neutral[400]!
              : HowWeatherColor.neutral[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Medium_14px(text: clothTypeToKorean(category, item.clothId)),
              SvgPicture.asset(
                isSelected
                    ? "assets/icons/chevron-up.svg"
                    : "assets/icons/chevron-down.svg",
              ),
            ],
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClothInfoCard(
                ref,
                colorIndexToColor(item.color),
                thicknessToText(item.thickness),
                infoProvider,
                selectedItemId: item.clothId,
              ),
            ),
        ],
      ),
    ),
  );
}

Color colorIndexToColor(int index) {
  switch (index) {
    case 1:
      return Colors.red;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.yellow;
    case 4:
      return Colors.green;
    case 5:
      return Colors.blue;
    case 6:
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

String thicknessToText(int value) {
  switch (value) {
    case 1:
      return "얇음";
    case 2:
      return "보통";
    case 3:
      return "두꺼움";
    default:
      return "알 수 없음";
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
    return upperMap[type] ?? "알 수 없음";
  } else if (category == 'outers') {
    return outerMap[type] ?? "알 수 없음";
  } else {
    return "알 수 없음";
  }
}
