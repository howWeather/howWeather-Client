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

  List<CategoryCloth> get clothesData => dummyClothesData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothes = clothesData.firstWhere((e) => e.category == category);

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_20px(text: "$text 선택하기")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          itemList(ref, clothes.clothList, category, havePalette),
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
                    context.push('/calendar/register');
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

  Widget itemList(WidgetRef ref, List<ClothGroup> clothGroups, String category,
      bool havePalette) {
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
                provider,
                infoProvider,
                category,
                havePalette,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
