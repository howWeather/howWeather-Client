import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherNavi.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class MyPage extends ConsumerWidget {
  MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: HowWeatherColor.white,
        surfaceTintColor: Colors.transparent,
        title: Bold_22px(
          text: "마이페이지",
          color: HowWeatherColor.black,
        ),
        centerTitle: true,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.push('/mypage/profile'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semibold_28px(text: "username"),
                    SvgPicture.asset("assets/icons/chevron-right.svg"),
                  ],
                ),
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
                  SvgPicture.asset("assets/icons/closet.svg"),
                  SizedBox(
                    width: 8,
                  ),
                  Semibold_20px(text: "나의 옷장"),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "의류 조회",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "의류 수정",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "의류 등록",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
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
                  SvgPicture.asset("assets/icons/setting.svg"),
                  SizedBox(
                    width: 8,
                  ),
                  Semibold_20px(text: "설정"),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "알림 설정",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "버전 정보",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "로그아웃",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "탈퇴",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
