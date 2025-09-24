import 'package:client/api/auth/auth_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:client/designs/toast.dart';
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
    return Container(
      color: HowWeatherColor.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: HowWeatherColor.white,
          appBar: AppBar(
            scrolledUnderElevation: 0,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/icons/winter.svg"),
                    SizedBox(width: 12),
                    Expanded(
                      child: Medium_16px(
                        text: "데이터가 쌓일수록 AI 추천이 더 정확해져요.",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/icons/rain.svg"),
                    SizedBox(width: 12),
                    Expanded(
                      child: Medium_16px(
                        text: "기록이 10개 이상 쌓이면, 딱 맞는 옷차림을 추천해드려요.",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/icons/moon.svg"),
                    SizedBox(width: 12),
                    Expanded(
                      child: Medium_16px(
                        text: "AI는 여러분의 데이터를 학습에 사용합니다.",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/icons/sun.svg"),
                    SizedBox(width: 12),
                    Expanded(
                      child: Medium_16px(
                        text: "데이터는 암호화되며 학습 외엔 사용하지 않아요.",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomSheet: bottomSheetWidget(context, ref),
        ),
      ),
    );
  }

  Widget bottomSheetWidget(BuildContext context, ref) {
    final isCheck = ref.watch(isCheckProvider);
    return GestureDetector(
      onTap: isCheck
          ? () async {
              if (!TapThrottler.canTap('signup_final')) return;

              // 🔥 회원가입 처리
              try {
                await ref
                    .read(authViewModelProvider.notifier)
                    .signUpWithFullData(signupData);
              } catch (e) {
                if (context.mounted) {
                  HowWeatherToast.show(context,
                      '${e.toString().replaceAll('Exception: ', '')}', true);
                }
                return; // 회원가입 실패시 여기서 중단
              }

              // ✅ 회원가입 성공 후 로그인
              try {
                await ref
                    .read(authViewModelProvider.notifier)
                    .login(signupData.loginId, signupData.password);

                // ✅ 로그인 성공시에만 페이지 이동
                if (context.mounted) {
                  context.push('/signUp/enrollClothes');
                }
              } catch (e) {
                if (context.mounted) {
                  HowWeatherToast.show(context,
                      '${e.toString().replaceAll('Exception: ', '')}', true);
                }
              }
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
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isCheck
                    ? HowWeatherColor.primary[900]
                    : HowWeatherColor.neutral[200],
              ),
              child: Center(
                child: Semibold_18px(
                  text: "회원가입",
                  color: isCheck
                      ? HowWeatherColor.white
                      : HowWeatherColor.neutral[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
