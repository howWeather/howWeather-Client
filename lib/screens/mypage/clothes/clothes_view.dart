import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/cloth_card.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:client/screens/exception/no_clothes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ClothesView extends ConsumerWidget {
  ClothesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothesAsync = ref.watch(closetProvider);

    return Container(
      color: HowWeatherColor.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: HowWeatherColor.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Medium_18px(text: "의류 조회"),
            centerTitle: true,
            leading: InkWell(
              onTap: () {
                context.pop();
                ref.resetClothProviders();
              },
              child: SvgPicture.asset(
                "assets/icons/chevron-left.svg",
                fit: BoxFit.scaleDown,
                height: 20,
                width: 20,
              ),
            ),
          ),
          body: clothesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: NoClothes()),
            data: (clothesData) {
              final uppers = clothesData.firstWhere(
                  (e) => e.category == "uppers",
                  orElse: () =>
                      CategoryCloth(category: "uppers", clothList: []));
              final outers = clothesData.firstWhere(
                  (e) => e.category == "outers",
                  orElse: () =>
                      CategoryCloth(category: "outers", clothList: []));

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
            item: item,
            allItems: allItems,
            category: category,
            havePalette: true, // havePalette
            haveDelete: false, // haveDelete
            text: "수정",
            initColor: item.color,
            initThickness: item.thickness,
          ),
        );
      }).toList(),
    );
  }
}
