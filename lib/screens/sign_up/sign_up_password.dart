import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/model/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final passwordProvider = StateProvider<String>((ref) => '');
final checkPasswordProvider = StateProvider<String>((ref) => '');
final obscureProvider = StateProvider<bool>((ref) => true);
final obscureCheckProvider = StateProvider<bool>((ref) => true);

// 영문 포함 여부
final hasLetterProvider = Provider<bool>((ref) {
  final password = ref.watch(passwordProvider);
  return RegExp(r'[a-zA-Z]').hasMatch(password);
});

// 숫자 포함 여부
final hasNumberProvider = Provider<bool>((ref) {
  final password = ref.watch(passwordProvider);
  return RegExp(r'\d').hasMatch(password);
});

// 특수문자 포함 여부
final hasSpecialCharProvider = Provider<bool>((ref) {
  final password = ref.watch(passwordProvider);
  return RegExp(r'[!@#\$%^&*()_+|~=`{}\[\]:";<>?,./]').hasMatch(password);
});

// 길이 조건 (8자 이상 20자 이하)
final isLengthValidProvider = Provider<bool>((ref) {
  final password = ref.watch(passwordProvider);
  return password.length >= 8 && password.length <= 20;
});

final isPasswordFormatValidProvider = Provider<bool>((ref) {
  return ref.watch(hasLetterProvider) &&
      ref.watch(hasNumberProvider) &&
      ref.watch(hasSpecialCharProvider) &&
      ref.watch(isLengthValidProvider);
});

final isPasswordMatchProvider = Provider<bool>((ref) {
  final password = ref.watch(passwordProvider);
  final checkPassword = ref.watch(checkPasswordProvider);
  return checkPassword.isNotEmpty && password == checkPassword;
});

// 최종 유효성
final isAllValidProvider = Provider<bool>((ref) {
  return ref.watch(isPasswordFormatValidProvider) &&
      ref.watch(isPasswordMatchProvider);
});

class SignUpPassword extends ConsumerWidget {
  final SignupData signupData;
  SignUpPassword({super.key, required this.signupData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkPassword = ref.watch(checkPasswordProvider);
    final isMatch = ref.watch(isPasswordMatchProvider);

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
          body: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: 0.48,
                    backgroundColor: HowWeatherColor.neutral[200],
                    color: HowWeatherColor.primary[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  SizedBox(height: 32),
                  Semibold_24px(text: "비밀번호를 입력해주세요."),
                  SizedBox(height: 60),
                  passwordTextField(ref),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/check.svg",
                        color: ref.watch(hasLetterProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Medium_16px(
                        text: "영문",
                        color: ref.watch(hasLetterProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      SvgPicture.asset(
                        "assets/icons/check.svg",
                        color: ref.watch(hasNumberProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Medium_16px(
                        text: "숫자",
                        color: ref.watch(hasNumberProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      SvgPicture.asset(
                        "assets/icons/check.svg",
                        color: ref.watch(hasSpecialCharProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Medium_16px(
                        text: "특수문자",
                        color: ref.watch(hasSpecialCharProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      SvgPicture.asset(
                        "assets/icons/check.svg",
                        color: ref.watch(isLengthValidProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Medium_16px(
                        text: "8~20자",
                        color: ref.watch(isLengthValidProvider)
                            ? HowWeatherColor.primary[900]
                            : HowWeatherColor.neutral[400],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  checkPasswordTextField(ref),
                  SizedBox(
                    height: 12,
                  ),
                  if (checkPassword.isNotEmpty && !isMatch)
                    Medium_16px(
                      text: "비밀번호가 일치하지 않습니다. 다시 입력해 주세요.",
                      color: HowWeatherColor.error,
                    ),
                ],
              ),
            ),
          ),
          bottomSheet: bottomSheetWidget(context, ref),
        ),
      ),
    );
  }

  Widget passwordTextField(ref) {
    final isObscure = ref.watch(obscureProvider);
    final password = ref.watch(passwordProvider); // 입력된 비밀번호 값

    return TextFormField(
      onChanged: (value) => ref.read(passwordProvider.notifier).state = value,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: HowWeatherColor.black,
      ),
      obscureText: isObscure,
      obscuringCharacter: '*',
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
        labelText: "영문, 숫자, 특수문자 포함 8-20자 이내",
        labelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: HowWeatherColor.neutral[200],
        ),
        suffixIcon: (password.isNotEmpty)
            ? IconButton(
                onPressed: () {
                  ref.read(obscureProvider.notifier).state =
                      !ref.read(obscureProvider.notifier).state;
                },
                icon: SvgPicture.asset(
                  isObscure
                      ? "assets/icons/eye-slash.svg"
                      : "assets/icons/eye-open.svg",
                  color: HowWeatherColor.black,
                ),
              )
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget checkPasswordTextField(ref) {
    final isCheckObscure = ref.watch(obscureCheckProvider);
    final checkPassword = ref.watch(checkPasswordProvider);
    final isMatch = ref.watch(isPasswordMatchProvider);

    return TextFormField(
      onChanged: (value) =>
          ref.read(checkPasswordProvider.notifier).state = value,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: HowWeatherColor.black,
      ),
      obscureText: isCheckObscure,
      obscuringCharacter: '*',
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
        labelText: "비밀번호 재입력",
        labelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: HowWeatherColor.neutral[200],
        ),
        suffixIcon: (checkPassword.isNotEmpty)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isMatch
                      ? SvgPicture.asset(
                          "assets/icons/circle-check.svg",
                          fit: BoxFit.scaleDown,
                        )
                      : SvgPicture.asset(
                          "assets/icons/circle-cancel.svg",
                          fit: BoxFit.scaleDown,
                        ),
                  IconButton(
                    onPressed: () {
                      ref.read(obscureCheckProvider.notifier).state =
                          !ref.read(obscureCheckProvider.notifier).state;
                    },
                    icon: SvgPicture.asset(
                      isCheckObscure
                          ? "assets/icons/eye-slash.svg"
                          : "assets/icons/eye-open.svg",
                      color: HowWeatherColor.black,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                ],
              )
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget bottomSheetWidget(BuildContext context, ref) {
    final isAllValid = ref.watch(isAllValidProvider);

    return GestureDetector(
      onTap: isAllValid
          ? () {
              final updatedData = signupData.copyWith(
                password: ref.read(passwordProvider),
              );
              context.push('/signUp/nickname', extra: updatedData);
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
