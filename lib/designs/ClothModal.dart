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
                false,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
