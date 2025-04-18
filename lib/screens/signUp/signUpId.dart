import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final idProvider = StateProvider<String>((ref) => '');
final duplicateCheckedProvider = StateProvider<bool>((ref) => false);
final duplicateProvider = StateProvider<String>((ref) => '');

// 아이디 형식 유효성 검사 (6~20자, 영문/숫자/특수문자 가능)
final isIdFormatValidProvider = Provider<bool>((ref) {
  final id = ref.watch(idProvider);
  final regex = RegExp(
    r'^[a-zA-Z0-9!@#$%^&*()_+|~=`{}\[\]:";\<>?,.\/]{8,20}$',
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
  return isFormatValid && isDuplicate && isChecked;
});

class SignUpId extends ConsumerWidget {
  SignUpId({super.key});

  Future<bool> checkIdDuplicate(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    return id == 'testtest';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDuplicate = ref.watch(duplicateProvider);
    final isAllValid = ref.watch(isAllValidProvider);
    final isDuplicateCheckEnabled = ref.watch(isDuplicateCheckEnabledProvider);
    final isFormatValid = ref.watch(isIdFormatValidProvider);

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
                      ref.read(duplicateCheckedProvider.notifier).state = false;
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
                      labelText: "아이디 입력",
                      labelStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: HowWeatherColor.neutral[200],
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: isAllValid
                          ? SvgPicture.asset(
                              "assets/icons/circle-check.svg",
                              fit: BoxFit.scaleDown,
                            )
                          : SvgPicture.asset(
                              "assets/icons/circle-cancel.svg",
                              fit: BoxFit.scaleDown,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: isDuplicateCheckEnabled
                      ? () async {
                          final id = ref.read(idProvider);
                          final result = await checkIdDuplicate(id);
                          ref.read(duplicateProvider.notifier).state =
                              result ? 'duplicated' : '';
                          ref.read(duplicateCheckedProvider.notifier).state =
                              true;
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDuplicateCheckEnabled
                          ? HowWeatherColor.primary[900]
                          : HowWeatherColor.neutral[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Medium_16px(
                      text: "중복 확인",
                      color: HowWeatherColor.white,
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
      bottomSheet: bottomSheetWidget(context, isAllValid),
    );
  }

  Widget bottomSheetWidget(BuildContext context, bool isAllValid) {
    return GestureDetector(
      onTap: isAllValid
          ? () {
              context.push('/signUp/password');
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
