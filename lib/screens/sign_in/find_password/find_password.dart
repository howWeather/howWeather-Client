import 'package:client/api/auth/auth_repository.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final identifierProvider = StateProvider<String?>((ref) => '');

class FindPassword extends ConsumerWidget {
  FindPassword({super.key});

  final findProvider = StateProvider<String>((ref) => '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 최종 유효성
    final isAllValidProvider = Provider<bool>((ref) {
      final isFormatValid = ref.watch(findProvider).isNotEmpty;
      return isFormatValid;
    });

    final isAllValid = ref.watch(isAllValidProvider);
    final findInput = ref.watch(findProvider);
    final result = ref.watch(identifierProvider);

    final shouldShowError = result == null && result != findInput;

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
              value: 0.5,
              backgroundColor: HowWeatherColor.neutral[200],
              color: HowWeatherColor.primary[900],
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 32),
            Semibold_24px(text: "아이디나 이메일을 입력해주세요."),
            SizedBox(height: 60),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (value) {
                      ref.read(findProvider.notifier).state = value;
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
                      labelText: "아이디나 이메일 입력",
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
                ),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            if (shouldShowError)
              Medium_16px(
                text: "존재하지 않는 계정 정보입니다.",
                color: HowWeatherColor.error,
              ),
          ],
        ),
      ),
      bottomSheet: bottomSheetWidget(context, isAllValid, ref),
    );
  }

  Widget bottomSheetWidget(
      BuildContext context, bool isAllValid, WidgetRef ref) {
    return GestureDetector(
      onTap: isAllValid
          ? () async {
              if (!TapThrottler.canTap('find_password')) return;
              final result =
                  await AuthRepository().resetPassword(ref.read(findProvider));
              ref.read(identifierProvider.notifier).state = result;
              print('result: $result');
              if (result != null) {
                context.push('/signIn/findPassword/sendEmail');
                ref.read(findProvider.notifier).state = '';
              }
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
