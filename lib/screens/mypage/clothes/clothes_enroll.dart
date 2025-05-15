import 'package:client/designs/ClothCard.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/designs/Palette.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/screens/mypage/clothes/clothes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final selectedEnrollClothProvider = StateProvider<int?>((ref) => null);

class ClothesEnroll extends ConsumerWidget {
  ClothesEnroll({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothes = ref.watch(clothesProvider);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "의류 등록"),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            context.pop();
          },
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
              buildGrid(clothes, "uppers", ref, context),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  color: HowWeatherColor.primary[900],
                  height: 1,
                ),
              ),
              sectionTitle("아우터", "assets/icons/clothes-outer.svg"),
              const SizedBox(height: 12),
              buildGrid(clothes, "outers", ref, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGrid(
    List<CategoryCloth> clothes,
    String category,
    WidgetRef ref,
    BuildContext context,
  ) {
    final selectedCategory =
        clothes.firstWhere((element) => element.category == category);

    final allItems =
        selectedCategory.clothList.expand((group) => group.items).toList();

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      childAspectRatio: 3 / 1,
      physics: const NeverScrollableScrollPhysics(),
      children: allItems.map((item) {
        return ClothEnrollCard(
          context,
          ref,
          category,
          item.clothType,
        );
      }).toList(),
    );
  }

  Widget ClothEnrollCard(BuildContext context, WidgetRef ref, category, type) {
    final selected = ref.watch(selectedEnrollClothProvider);
    final isSelected = selected == type;

    return InkWell(
      onTap: () {
        ref.read(selectedEnrollClothProvider.notifier).state =
            isSelected ? null : type;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Palette(
              context: context,
              ref: ref,
              text: '등록',
            );
          },
        );
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
          text: clothTypeToKorean(category, type),
          color: isSelected ? HowWeatherColor.white : HowWeatherColor.black,
        )),
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
