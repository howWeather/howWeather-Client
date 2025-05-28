import 'package:client/designs/cloth_info_card.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/screens/mypage/clothes/clothes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClothCard extends ConsumerStatefulWidget {
  final BuildContext context;
  final ClothItem item;
  final List<ClothItem> allItems;
  final WidgetRef ref;
  final String category;
  final int initColor;
  final int initThickness;
  final bool havePalette;
  final bool haveDelete;
  final String text;

  const ClothCard({
    super.key,
    required this.context,
    required this.item,
    required this.allItems,
    required this.ref,
    required this.category,
    required this.initColor,
    required this.initThickness,
    this.havePalette = true,
    this.haveDelete = false,
    this.text = "등록",
  });

  @override
  ConsumerState<ClothCard> createState() => _ClothCardState();
}

class _ClothCardState extends ConsumerState<ClothCard> {
  late StateProvider<int?> selectedProvider;
  late StateProvider<int?> infoProvider;

  @override
  void initState() {
    super.initState();

    // 카테고리에 따른 Provider 설정
    if (widget.category == "uppers") {
      selectedProvider = selectedUpperProvider;
      infoProvider = selectedUpperInfoProvider;
    } else if (widget.category == "outers") {
      selectedProvider = selectedOuterProvider;
      infoProvider = selectedOuterInfoProvider;
    }

    // 초기값 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(colorProvider.notifier).state = widget.initColor;
      ref.read(thicknessProvider.notifier).state = widget.initThickness;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedProvider);
    final isSelected = selected == widget.item.clothId;
    final sameTypeItems = widget.allItems
        .where((i) => i.clothType == widget.item.clothType)
        .toList();

    return InkWell(
      onTap: () {
        final isNowSelected =
            ref.read(selectedProvider.notifier).state == widget.item.clothId;
        ref.read(selectedProvider.notifier).state =
            isNowSelected ? null : widget.item.clothId;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? HowWeatherColor.primary[50] : HowWeatherColor.white,
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
                Medium_14px(
                  text:
                      clothTypeToKorean(widget.category, widget.item.clothType),
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
                      text: widget.text,
                      context: widget.context,
                      ref: widget.ref,
                      color: i.color,
                      thicknessLabel: i.thickness,
                      provider: infoProvider,
                      selectedItemId: i.clothId,
                      selectedItem: i,
                      havePalette: widget.havePalette,
                      haveDelete: widget.haveDelete,
                      category: widget.category,
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
    return upperMap[type] ?? "알 수 없음";
  } else if (category == 'outers') {
    return outerMap[type] ?? "알 수 없음";
  } else {
    return "알 수 없음";
  }
}
