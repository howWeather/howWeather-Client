import 'package:client/designs/Palette.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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

class ClothesEnroll extends ConsumerWidget {
  ClothesEnroll({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "의류 등록"),
        centerTitle: true,
        leading: InkWell(
          onTap: () => context.go('/mypage'),
          child: SvgPicture.asset(
            "assets/icons/chevron-left.svg",
            fit: BoxFit.scaleDown,
            height: 20,
            width: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              sectionTitle("상의", "assets/icons/clothes-upper.svg"),
              const SizedBox(height: 12),
              buildGrid(context, ref, "uppers", upperMap),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  color: HowWeatherColor.primary[900],
                  height: 1,
                ),
              ),
              sectionTitle("아우터", "assets/icons/clothes-outer.svg"),
              const SizedBox(height: 12),
              buildGrid(context, ref, "outers", outerMap),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGrid(BuildContext context, WidgetRef ref, String category,
      Map<int, String> itemMap) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      childAspectRatio: 3 / 1,
      physics: const NeverScrollableScrollPhysics(),
      children: itemMap.keys.map((type) {
        return ClothEnrollCard(context, ref, category, type, itemMap[type]!);
      }).toList(),
    );
  }

  Widget ClothEnrollCard(BuildContext context, WidgetRef ref, String category,
      int type, String label) {
    final selectedMap = ref.watch(selectedEnrollClothProvider);
    final selectedType = selectedMap[category];
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () {
        final selectedMap = ref.read(selectedEnrollClothProvider);
        final currentSelectedType = selectedMap[category];

        // 선택된 타입이 같으면 null로, 아니면 새 값으로 설정
        final newType = (currentSelectedType == type) ? null : type;

        // 새 Map 생성 (immutability 유지)
        final newSelectedMap = Map<String, int?>.from(selectedMap);
        newSelectedMap[category] = newType;

        ref.read(selectedEnrollClothProvider.notifier).state = newSelectedMap;

        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return WillPopScope(
              onWillPop: () async {
                // 다이얼로그 닫을 때 선택 초기화
                ref.resetClothInfoProviders();
                return true;
              },
              child: Palette(
                text: '등록',
                category: category,
                initialColor: 1,
                initialThickness: 1,
              ),
            );
          },
        ).then((_) {
          // 다이얼로그 닫힌 후에도 초기화
          final resetMap =
              Map<String, int?>.from(ref.read(selectedEnrollClothProvider));
          resetMap[category] = null;
          ref.read(selectedEnrollClothProvider.notifier).state = resetMap;
          ref.read(colorProvider.notifier).state = 1;
          ref.read(thicknessProvider.notifier).state = 1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? HowWeatherColor.primary[900] : HowWeatherColor.white,
          border: Border.all(color: HowWeatherColor.neutral[200]!, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Medium_16px(
            text: label,
            color: isSelected ? HowWeatherColor.white : HowWeatherColor.black,
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SvgPicture.asset(iconPath),
          const SizedBox(width: 12),
          Medium_20px(text: title),
        ],
      ),
    );
  }
}
