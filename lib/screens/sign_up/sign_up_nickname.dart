import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final nicknameProvider = StateProvider<String>((ref) => '');

// 아이디 형식 유효성 검사 (한글, 영문, 숫자, 특수문자 사용 가능, 2~10자 이내)
final isFormatValidProvider = Provider<bool>((ref) {
  final nickname = ref.watch(nicknameProvider);
  final regex = RegExp(
    r'^[ㄱ-ㅎ가-힣a-zA-Z0-9!@#$%^&*()_+|~=`{}\[\]:";\<>?,.\/]{2,10}$',
  );
  return regex.hasMatch(nickname);
});

final isAllValidProvider = Provider<bool>((ref) {
  final formatValid = ref.watch(isFormatValidProvider);
  return formatValid;
});

class SignUpNickname extends ConsumerWidget {
  final SignupData signupData;
  SignUpNickname({super.key, required this.signupData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: HowWeatherColor.white,
      child: SafeArea(
        child: Scaffold(
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
                  value: 0.64,
                  backgroundColor: HowWeatherColor.neutral[200],
                  color: HowWeatherColor.primary[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                SizedBox(
                  height: 32,
                ),
                Semibold_24px(text: "닉네임을 입력해주세요."),
                SizedBox(
                  height: 60,
                ),
                TextFormField(
                  onChanged: (value) =>
                      ref.read(nicknameProvider.notifier).state = value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: HowWeatherColor.black),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: HowWeatherColor.neutral[100]!,
                        width: 3,
                      ),
                    ),
                    filled: true,
                    fillColor: HowWeatherColor.neutral[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: HowWeatherColor.neutral[200]!,
                        width: 3,
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: "한글, 영문, 숫자, 특수문자 사용 가능, 2~10자 이내",
                    labelStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HowWeatherColor.neutral[200],
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
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
    final isAllValid = ref.watch(isAllValidProvider);
    return GestureDetector(
      onTap: isAllValid
          ? () {
              final updatedData = signupData.copyWith(
                nickname: ref.read(nicknameProvider),
              );
              context.push('/signUp/personal', extra: updatedData);
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isAllValid
                ? HowWeatherColor.primary[900]
                : HowWeatherColor.neutral[200],
          ),
          child: Center(
            child: Semibold_24px(
              text: "다음",
              color: HowWeatherColor.white,
            ),
          ),
        ),
      ),
    );
  }
}
