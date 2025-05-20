import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/ClothCard.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/model/cloth_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return Center(child: Text('불러오기 실패'));
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
