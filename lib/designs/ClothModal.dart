import 'package:client/designs/ClothCard.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget ClothModal(BuildContext context, WidgetRef ref, provider, infoProvider) {
  return AlertDialog(
    backgroundColor: HowWeatherColor.white,
    title: Center(child: Semibold_20px(text: "상의 선택하기")),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClothCard("민소매", ref, provider, infoProvider),
        SizedBox(
          height: 12,
        ),
        ClothCard("반소매", ref, provider, infoProvider),
        SizedBox(
          height: 12,
        ),
        ClothCard("긴소매", ref, provider, infoProvider),
        SizedBox(
          height: 12,
        ),
        ClothCard("니트", ref, provider, infoProvider),
        SizedBox(
          height: 12,
        ),
        ClothCard("조끼", ref, provider, infoProvider),
        SizedBox(
          height: 12,
        ),
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
