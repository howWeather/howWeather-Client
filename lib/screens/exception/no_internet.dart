import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

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
              "assets/icons/wifi-off.svg",
              color: HowWeatherColor.neutral[300],
            ),
            SizedBox(
              height: 32,
            ),
            Medium_18px(
              text: '현재 접속이 원활하지 않습니다.',
              color: HowWeatherColor.neutral[400],
            ),
            SizedBox(
              height: 12,
            ),
            Medium_16px(
              text: "잠시후 다시 시도해 주세요.",
              color: HowWeatherColor.neutral[400],
            ),
          ],
        ),
      ),
    );
  }
}
