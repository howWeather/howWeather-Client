import 'package:client/api/auth/auth_view_model.dart';
import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
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
                Medium_14px(text: "AI가 학습을 진행할수록 정확해진다 어쩌구"),
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
                Medium_14px(text: "언제부터 AI 가 의상을 추천해주는지 일정 대략 적어주기"),
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
                Medium_14px(text: "AI 학습에 당신의 데이터를 사용할 거라는 거 명시"),
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
                Medium_14px(text: "데이터는 암호화 + AI 학습용으로만 쓴다"),
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
              await ref
                  .read(authViewModelProvider.notifier)
                  .signUpWithFullData(signupData);
              context.push('/');
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
