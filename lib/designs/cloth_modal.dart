import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/cloth_card.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:client/screens/calendar/register/view.dart';
import 'package:client/screens/exception/no_clothes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ClothModal extends ConsumerWidget {
  final BuildContext context;
  final WidgetRef ref;
  final String text;
  final String category;
  final provider;
  final infoProvider;
  final bool havePalette;

  ClothModal({
    Key? key,
    required this.context,
    required this.ref,
    required this.text,
    required this.category,
    required this.provider,
    required this.infoProvider,
    this.havePalette = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothesAsync = ref.watch(closetProvider);

    if (clothesAsync is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (clothesAsync is AsyncError) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: HowWeatherColor.white,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            'assets/icons/cancel.svg',
                            color: HowWeatherColor.neutral[700],
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: NoClothes(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final clothesData = clothesAsync.value!;
    final clothes = clothesData.firstWhere((e) => e.category == category);

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_20px(text: "$text 선택하기")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          itemList(context, ref, clothes.clothList, category),
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
                    print('선택 확인 ${ref.watch(infoProvider)}');
                    context.pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HowWeatherColor.primary[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Medium_14px(
                        text: "등록",
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
