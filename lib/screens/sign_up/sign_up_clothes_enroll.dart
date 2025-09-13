import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/designs/Palette.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:client/screens/mypage/clothes/clothes_enroll.dart'
    hide selectedEnrollClothProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SignUpEnrollClothes extends ConsumerWidget {
  SignUpEnrollClothes({super.key});

  final isAllValidProvider = Provider<bool>((ref) {
    return ref.watch(closetProvider).hasValue;
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllValid = ref.watch(isAllValidProvider);
    return Container(
      color: HowWeatherColor.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: HowWeatherColor.white,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            title: Medium_18px(text: "보유한 의류를 등록해주세요!"),
            centerTitle: true,
            automaticallyImplyLeading: false,
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
          bottomSheet: bottomSheetWidget(context, isAllValid, ref),
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
          ref.resetClothInfoProviders();
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

  Widget bottomSheetWidget(
      BuildContext context, bool isAllValid, WidgetRef ref) {
    return GestureDetector(
      onTap: isAllValid
          ? () {
              if (!TapThrottler.canTap('signup_clothes')) return;
              context.push('/');
            }
          : null,
      child: Container(
        color: HowWeatherColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAllValid)
              InkWell(
                onTap: () {
                  if (!TapThrottler.canTap('signup_clothes')) return;
                  context.push('/');
                },
                child: Medium_20px(text: '나중에 등록하기'),
              ),
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: HowWeatherColor.white,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isAllValid
                      ? HowWeatherColor.primary[900]
                      : HowWeatherColor.neutral[200],
                ),
                child: Center(
                  child: Semibold_24px(
                    text: "다음",
                    color: HowWeatherColor.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
