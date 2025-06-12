import 'package:client/api/auth/auth_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:client/model/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final isCheckProvider = StateProvider<bool>((ref) => false);

class SignUpCheck extends ConsumerWidget {
  final SignupData signupData;
  SignUpCheck({super.key, required this.signupData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "회원가입"),
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
              value: 1,
              backgroundColor: HowWeatherColor.neutral[200],
              color: HowWeatherColor.primary[900],
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(
              height: 32,
            ),
            Semibold_24px(text: "날씨어때의 AI를 소개합니다!"),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                SvgPicture.asset("assets/icons/winter.svg"),
                SizedBox(
                  width: 12,
                ),
                Medium_16px(text: "데이터가 쌓일수록 AI 추천이 더 정확해져요."),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                SvgPicture.asset("assets/icons/rain.svg"),
                SizedBox(
                  width: 12,
                ),
                Medium_16px(text: "기록이 10개 이상 쌓이면, 딱 맞는 옷차림을 추천해드려요."),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                SvgPicture.asset("assets/icons/moon.svg"),
                SizedBox(
                  width: 12,
                ),
                Medium_16px(text: "AI는 여러분의 데이터를 학습에 사용합니다."),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                SvgPicture.asset("assets/icons/sun.svg"),
                SizedBox(
                  width: 12,
                ),
                Medium_16px(text: "데이터는 암호화되며 학습 외엔 사용하지 않아요."),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: bottomSheetWidget(context, ref),
    );
  }

  Widget bottomSheetWidget(BuildContext context, ref) {
    final isCheck = ref.watch(isCheckProvider);
    return GestureDetector(
      onTap: isCheck
          ? () async {
              if (!TapThrottler.canTap('signup_final')) return;
              await ref
                  .read(authViewModelProvider.notifier)
                  .signUpWithFullData(signupData);
              await ref
                  .read(authViewModelProvider.notifier)
                  .login(signupData.loginId, signupData.password);
              context.push('/signUp/enrollClothes');
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semibold_20px(text: "위의 내용을 모두 확인하였습니다."),
                InkWell(
                  onTap: () {
                    ref.read(isCheckProvider.notifier).state =
                        !ref.read(isCheckProvider); // 토글 형식
                  },
                  child: SvgPicture.asset(
                    isCheck
                        ? "assets/icons/circle-check.svg"
                        : "assets/icons/circle-check-none.svg",
                    width: 24,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 24,
            ),
            Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isCheck
                    ? HowWeatherColor.primary[900]
                    : HowWeatherColor.neutral[200],
              ),
              child: Center(
                child: Semibold_24px(
                  text: "회원가입",
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
