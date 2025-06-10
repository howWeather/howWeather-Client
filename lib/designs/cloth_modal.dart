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

class ClothModal extends ConsumerWidget {
  final String text;
  final String category;
  final bool havePalette;

  const ClothModal({
    Key? key,
    required this.text,
    required this.category,
    this.havePalette = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothesAsync = ref.watch(closetProvider);

    if (clothesAsync is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (clothesAsync is AsyncError) {
      return _buildErrorDialog(context);
    }

    final clothesData = clothesAsync.value!;
    final clothes = clothesData.firstWhere((e) => e.category == category);

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_20px(text: "$text 선택하기")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItemList(context, ref, clothes.clothList, category),
          const SizedBox(height: 16),
          _buildBottomButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildErrorDialog(BuildContext context) {
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
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgPicture.asset(
                        'assets/icons/cancel.svg',
                        color: HowWeatherColor.neutral[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: const NoClothes(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(
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
            havePalette: havePalette,
            haveDelete: false,
            text: text,
            initColor: item.color,
            initThickness: item.thickness,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              // 취소 시 선택 초기화
              ref.read(selectedClothProvider(category).notifier).state = null;
              ref.read(selectedClothInfoProvider(category).notifier).state =
                  null;
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HowWeatherColor.neutral[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Medium_14px(text: "취소")),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _handleConfirm(context, ref);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HowWeatherColor.primary[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Medium_14px(
                  text: "등록",
                  color: HowWeatherColor.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleConfirm(BuildContext context, WidgetRef ref) {
    final selectedInfo = ref.read(selectedClothInfoProvider(category));

    if (selectedInfo != null) {
      // 선택된 아이템을 등록 provider에 저장
      if (category == "uppers") {
        // allItems에서 해당 clothId를 가진 실제 ClothItem 찾기
        final clothesAsync = ref.read(closetProvider);
        if (clothesAsync.hasValue) {
          final clothesData = clothesAsync.value!;
          final clothes = clothesData.firstWhere((e) => e.category == category);
          final allItems = clothes.clothList.expand((g) => g.items).toList();
          final selectedItem =
              allItems.firstWhere((item) => item == selectedInfo);
          ref.read(registerUpperProvider.notifier).state = selectedItem;
        }
      } else if (category == "outers") {
        final clothesAsync = ref.read(closetProvider);
        if (clothesAsync.hasValue) {
          final clothesData = clothesAsync.value!;
          final clothes = clothesData.firstWhere((e) => e.category == category);
          final allItems = clothes.clothList.expand((g) => g.items).toList();
          final selectedItem =
              allItems.firstWhere((item) => item == selectedInfo);
          ref.read(registerOuterProvider.notifier).state = selectedItem;
        }
      }
    }

    // 모달 닫기
    context.pop();

    // 선택 상태 초기화
    ref.read(selectedClothProvider(category).notifier).state = null;
    ref.read(selectedClothInfoProvider(category).notifier).state = null;
  }
}
