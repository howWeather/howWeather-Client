import 'package:client/designs/ClothCard.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final selectedClothProvider = StateProvider<int?>((ref) => null);
final selectedClothInfoProvider = StateProvider<int?>((ref) => null);
final thicknessProvider = StateNotifierProvider<ThicknessNotifier, int>((ref) {
  return ThicknessNotifier();
});
final colorProvider = StateNotifierProvider<ColorNotifier, int>((ref) {
  return ColorNotifier();
});

class ThicknessNotifier extends StateNotifier<int> {
  ThicknessNotifier() : super(1); // 기본값: 1 (얇음)

  void updateThickness(int newThickness) {
    state = newThickness;
  }
}

class ColorNotifier extends StateNotifier<int> {
  ColorNotifier() : super(1); // 기본값: 1 (빨강)

  void updateColor(int newColor) {
    state = newColor;
  }
}

final dummyClothesData = [
  CategoryCloth(
    category: "uppers",
    clothList: [
      ClothGroup(
        clothType: 7,
        items: [
          ClothItem(clothType: 7, color: 6, thickness: 1, clothId: 8),
        ],
      ),
      ClothGroup(
        clothType: 9,
        items: [
          ClothItem(clothType: 9, color: 1, thickness: 3, clothId: 3),
        ],
      ),
    ],
  ),
  CategoryCloth(
    category: "outers",
    clothList: [
      ClothGroup(
        clothType: 1,
        items: [
          ClothItem(clothType: 1, color: 1, thickness: 1, clothId: 2),
        ],
      ),
    ],
  ),
];

class ClothesView extends ConsumerWidget {
  ClothesView({super.key});

  final List<CategoryCloth> clothesData = dummyClothesData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uppers = clothesData.firstWhere((e) => e.category == "uppers");
    final outers = clothesData.firstWhere((e) => e.category == "outers");

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "의류 조회"),
        centerTitle: true,
        leading: InkWell(
          onTap: () => context.pop(),
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
              itemList(context, ref, uppers.clothList, "uppers"),
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  color: HowWeatherColor.primary[900],
                  height: 1,
                ),
              ),
              sectionTitle("아우터", "assets/icons/clothes-outer.svg"),
              itemList(context, ref, outers.clothList, "outers"),
            ],
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

  Widget itemList(BuildContext context, WidgetRef ref,
      List<ClothGroup> clothGroups, String category) {
    return Column(
      children: clothGroups.map((group) {
        return Column(
          children: group.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClothCard(
                context,
                item, // ClothItem 전달
                ref,
                selectedClothProvider,
                selectedClothInfoProvider,
                category,
                true,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
