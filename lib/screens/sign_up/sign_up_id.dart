import 'package:client/api/auth/auth_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:client/model/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final idProvider = StateProvider<String>((ref) => '');
final duplicateCheckedProvider = StateProvider<bool>((ref) => false);
final duplicateProvider = StateProvider<String>((ref) => '');
final isVerificationSuccessProvider = StateProvider<bool>((ref) => false);

// 아이디 형식 유효성 검사 (6~20자, 영문/숫자/특수문자 가능)
final isIdFormatValidProvider = Provider<bool>((ref) {
  final id = ref.watch(idProvider);
  final regex = RegExp(
    r'^[a-zA-Z0-9!@#$%^&*()_+|~=`{}\[\]:";\<>?,.\/]{6,20}$',
  );
  return regex.hasMatch(id);
});

// 중복확인 버튼 활성화 조건
final isDuplicateCheckEnabledProvider = Provider<bool>((ref) {
  final isFormatValid = ref.watch(isIdFormatValidProvider);
  final isChecked = ref.watch(duplicateCheckedProvider);
  return isFormatValid && !isChecked;
});

// 최종 유효성
final isAllValidProvider = Provider<bool>((ref) {
  final isFormatValid = ref.watch(isIdFormatValidProvider);
  final isDuplicate = ref.watch(duplicateProvider).isEmpty;
  final isChecked = ref.watch(duplicateCheckedProvider);
  final verification = ref.watch(isVerificationSuccessProvider);
  return isFormatValid && isDuplicate && isChecked && (verification == true);
});

class SignUpId extends ConsumerWidget {
  final SignupData signupData;
  SignUpId({super.key, required this.signupData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDuplicate = ref.watch(duplicateProvider);
    final isAllValid = ref.watch(isAllValidProvider);
    final isDuplicateCheckEnabled = ref.watch(isDuplicateCheckEnabledProvider);
    final isFormatValid = ref.watch(isIdFormatValidProvider);

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
                  value: 0.32,
                  backgroundColor: HowWeatherColor.neutral[200],
                  color: HowWeatherColor.primary[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                SizedBox(height: 32),
                Semibold_24px(text: "아이디를 입력해주세요."),
                SizedBox(height: 60),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          ref.read(idProvider.notifier).state = value;
                          ref.read(duplicateProvider.notifier).state = '';
                          ref.read(duplicateCheckedProvider.notifier).state =
                              false;
                        },
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: HowWeatherColor.black,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: HowWeatherColor.neutral[200]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: HowWeatherColor.neutral[50],
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: HowWeatherColor.primary[900]!,
                              width: 2,
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "아이디 입력",
                          labelStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: HowWeatherColor.neutral[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          suffixIcon: isDuplicateCheckEnabled
                              ? null
                              : SvgPicture.asset(
                                  isAllValid
                                      ? "assets/icons/circle-check.svg"
                                      : "assets/icons/circle-cancel.svg",
                                  fit: BoxFit.scaleDown,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: isDuplicateCheckEnabled
                          ? () async {
                              if (!TapThrottler.canTap('signup_id')) return;
                              final viewModel =
                                  ref.read(authViewModelProvider.notifier);
                              try {
                                await viewModel
                                    .verifyloginId(ref.read(idProvider));
                                ref
                                    .read(
                                        isVerificationSuccessProvider.notifier)
                                    .state = true;
                                ref
                                    .read(duplicateCheckedProvider.notifier)
                                    .state = true;
                              } catch (_) {
                                ref
                                    .read(
                                        isVerificationSuccessProvider.notifier)
                                    .state = false;
                              }
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDuplicateCheckEnabled
                              ? HowWeatherColor.primary[900]
                              : HowWeatherColor.neutral[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Medium_16px(
                          text: "중복 확인",
                          color: isDuplicateCheckEnabled
                              ? HowWeatherColor.white
                              : HowWeatherColor.neutral[400],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                if (isFormatValid)
                  SizedBox()
                else
                  Medium_16px(
                    text: "아이디는 영문, 숫자, 특수문자를 포함할 수 있으며 \n6~20자 이내여야 합니다.",
                    color: HowWeatherColor.error,
                  ),
                if (isDuplicate == 'duplicated')
                  Medium_16px(
                    text: "이미 존재하는 아이디입니다.",
                    color: HowWeatherColor.error,
                  ),
                if (isAllValid)
                  Medium_16px(
                    text: "사용 가능한 아이디입니다.",
                    color: HowWeatherColor.primary[900],
                  ),
              ],
            ),
          ),
          bottomSheet: bottomSheetWidget(context, isAllValid, ref),
        ),
      ),
    );
  }

  Widget bottomSheetWidget(
      BuildContext context, bool isAllValid, WidgetRef ref) {
    return GestureDetector(
      onTap: isAllValid
          ? () {
              final updatedData = signupData.copyWith(
                loginId: ref.read(idProvider),
              );
              context.push('/signUp/password', extra: updatedData);
              ref.read(idProvider.notifier).state = '';
              ref.read(duplicateProvider.notifier).state = '';
              ref.read(duplicateCheckedProvider.notifier).state = false;
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isAllValid
                ? HowWeatherColor.primary[900]
                : HowWeatherColor.neutral[200],
          ),
          child: Center(
            child: Semibold_18px(
              text: "다음",
              color: isAllValid
                  ? HowWeatherColor.white
                  : HowWeatherColor.neutral[400],
            ),
          ),
        ),
      ),
    );
  }
}
