import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class NoClothes extends StatelessWidget {
  const NoClothes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/closet-off.svg",
            ),
            SizedBox(
              height: 32,
            ),
            Medium_18px(
              text: '현재 등록한 의류가 없습니다.',
              color: HowWeatherColor.neutral[700],
            ),
            SizedBox(
              height: 12,
            ),
            Medium_16px(
              text: "마이페이지에서 의류를 등록해보세요!",
              color: HowWeatherColor.neutral[400],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                context.go('/mypage');
                context.push('/mypage/clothes/enroll');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: HowWeatherColor.primary[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Semibold_24px(
                  text: "의류 등록하러 가기",
                  color: HowWeatherColor.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
