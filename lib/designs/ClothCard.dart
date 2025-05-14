import 'package:client/designs/ClothInfoCard.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

Widget ClothCard(text, WidgetRef ref, provider, infoProvider) {
  final selected = ref.watch(provider);

  final isSelected = selected == text;

  return InkWell(
    onTap: () {
      ref.read(provider.notifier).state = isSelected ? null : text;
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? HowWeatherColor.primary[50] : HowWeatherColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isSelected
                ? HowWeatherColor.neutral[400]!
                : HowWeatherColor.neutral[200]!,
            width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Medium_14px(text: text),
              isSelected
                  ? SvgPicture.asset("assets/icons/chevron-up.svg")
                  : SvgPicture.asset("assets/icons/chevron-down.svg"),
            ],
          ),
          isSelected
              ? Container(
                  padding: EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      ClothInfoCard(
                          ref, HowWeatherColor.black, "얇음", infoProvider),
                      ClothInfoCard(
                          ref, HowWeatherColor.black, "보통", infoProvider),
                      ClothInfoCard(
                          ref, HowWeatherColor.black, "두꺼움", infoProvider),
                    ],
                  ))
              : Container(),
        ],
      ),
    ),
  );
}
