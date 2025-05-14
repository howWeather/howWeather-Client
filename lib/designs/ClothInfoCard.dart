import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget ClothInfoCard(WidgetRef ref, Color color, String thicknessLabel,
    StateProvider<int?> provider,
    {required int selectedItemId}) {
  final selected = ref.watch(provider);
  final isSelected = selected == selectedItemId;

  return InkWell(
    onTap: () {
      ref.read(provider.notifier).state = isSelected ? null : selectedItemId;
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: HowWeatherColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? HowWeatherColor.primary[900]!
              : HowWeatherColor.white,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Medium_14px(text: "색깔"),
          const SizedBox(width: 12),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: HowWeatherColor.neutral[200]!,
                width: 2,
              ),
            ),
          ),
          const Spacer(),
          Medium_14px(text: "두께"),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: HowWeatherColor.primary[600],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Medium_14px(
              text: thicknessLabel,
              color: HowWeatherColor.white,
            ),
          ),
        ],
      ),
    ),
  );
}
