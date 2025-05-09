import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class Profile extends ConsumerWidget {
  Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "프로필"),
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
            titleCard("닉네임"),
            ContainerCard("test"),
            SizedBox(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Medium_18px(text: "이메일"),
            ),
            Row(
              children: [
                Expanded(flex: 2, child: ContainerCard("test")),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Medium_18px(
                    text: "@",
                    color: HowWeatherColor.neutral[200],
                  ),
                ),
                Expanded(flex: 1, child: ContainerCard("test.com")),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Medium_18px(text: "아이디"),
            ),
            ContainerCard("testid"),
            SizedBox(
              height: 8,
            ),
            titleCard("체질"),
            ContainerCard("평범한 것 같아요"),
            SizedBox(
              height: 8,
            ),
            titleCard("성별"),
            ContainerCard("여"),
            SizedBox(
              height: 8,
            ),
            titleCard("나이"),
            ContainerCard("10대"),
          ],
        ),
      ),
    );
  }

  Widget titleCard(text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Medium_18px(text: text),
          Medium_18px(
            text: "변경",
            color: HowWeatherColor.primary[900],
          ),
        ],
      ),
    );
  }

  Widget ContainerCard(text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: HowWeatherColor.neutral[100]!, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Medium_16px(text: text),
    );
  }
}
