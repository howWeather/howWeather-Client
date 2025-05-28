import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/cloth_card.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/screens/mypage/clothes/clothes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ClothesDelete extends ConsumerWidget {
  ClothesDelete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothesAsync = ref.watch(closetProvider);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "의류 삭제"),
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
      body: clothesAsync.when(
        data: (clothesData) {
          final uppers = clothesData.firstWhere((e) => e.category == "uppers");
          final outers = clothesData.firstWhere((e) => e.category == "outers");

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  sectionTitle("상의", "assets/icons/clothes-upper.svg"),
                  itemList(context, ref, uppers.clothList, "uppers"),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
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

  Widget itemList(
    BuildContext context,
    WidgetRef ref,
    List<ClothGroup> clothGroups,
    String category,
  ) {
    final allItems = clothGroups.expand((g) => g.items).toList();
    final seenTypes = <int>{};
    final filteredItems = <ClothItem>[];

    // clothType별로 하나씩만 남기기
    for (final item in allItems) {
      if (!seenTypes.contains(item.clothType)) {
        seenTypes.add(item.clothType);
        filteredItems.add(item);
      }
    }

    return Column(
      children: filteredItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClothCard(
            context: context,
            item: item,
            allItems: allItems,
            ref: ref,
            category: category,
            havePalette: false, // havePalette
            haveDelete: true, // haveDelete
            initColor: item.color,
            initThickness: item.thickness,
          ),
        );
      }).toList(),
    );
  }
}
