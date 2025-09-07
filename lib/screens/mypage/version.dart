import 'package:client/api/alarm/alarm_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class Version extends ConsumerWidget {
  Version({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: HowWeatherColor.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: HowWeatherColor.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Medium_18px(text: "버전 정보"),
            centerTitle: true,
            leading: InkWell(
              onTap: () {
                context.pop();
              },
              child: SvgPicture.asset(
                "assets/icons/chevron-left.svg",
                fit: BoxFit.scaleDown,
                height: 20,
                width: 20,
              ),
            ),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/version.png',
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Medium_18px(text: "날씨어때"),
                        SizedBox(height: 4),
                        Medium_16px(
                            text: "1.0.0", color: HowWeatherColor.neutral[400]),
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: HowWeatherColor.primary[900]!),
                          borderRadius: BorderRadius.circular(16)),
                      child: Medium_14px(
                          text: "최신 버전", color: HowWeatherColor.primary[900]!),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(
                    color: HowWeatherColor.primary[900],
                    height: 1,
                  ),
                ),
                Row(
                  children: [
                    Medium_18px(text: "문의하기"),
                    Spacer(),
                    Medium_16px(
                        text: "howWeather2025@gmail.com",
                        color: HowWeatherColor.neutral[400]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget TimeNotification(
      String title, String content, bool isOn, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Medium_18px(text: title),
              SizedBox(height: 4),
              Medium_16px(text: content, color: HowWeatherColor.neutral[400]),
            ],
          ),
          Spacer(),
          CupertinoSwitch(
            value: isOn,
            onChanged: (_) => onToggle(),
            activeColor: HowWeatherColor.primary[900],
          ),
        ],
      ),
    );
  }
}
