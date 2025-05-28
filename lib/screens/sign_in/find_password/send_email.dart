import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/screens/sign_in/find_password/find_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SendEmail extends ConsumerWidget {
  SendEmail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "비밀번호 찾기"),
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: HowWeatherColor.neutral[200],
              color: HowWeatherColor.primary[900],
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 32),
            Semibold_24px(text: "회원가입 시 입력하신 이메일로\n임시 비밀번호를 전송하였습니다 🎉"),
            SizedBox(
              height: 12,
            ),
            Medium_16px(
              text: "${ref.read(identifierProvider)} 메일함을 확인해주세요!",
              color: HowWeatherColor.primary[900],
            ),
          ],
        ),
      ),
      bottomSheet: bottomSheetWidget(context, ref),
    );
  }

  Widget bottomSheetWidget(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.push('/signIn');
      },
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/Info.svg',
                  color: HowWeatherColor.neutral[600],
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Medium_14px(
                  text: '메일이 오지 않은 경우 스팸함을 확인해주세요.',
                  color: HowWeatherColor.neutral[600],
                )),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/Info.svg',
                  color: HowWeatherColor.neutral[600],
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Medium_14px(
                    text: '임시 비밀번호로 로그인 후 보안을 위해 비밀번호를 변경해주세요.',
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: HowWeatherColor.primary[900],
                ),
                child: Center(
                  child: Semibold_24px(
                    text: "임시 비밀번호로 로그인 하기",
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
