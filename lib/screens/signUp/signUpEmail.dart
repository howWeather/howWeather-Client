import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SignUpEmail extends ConsumerWidget {
  SignUpEmail({super.key});

  final emailIdProvider = StateProvider<String>((ref) => '');
  final emailDomainProvider = StateProvider<String>((ref) => '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllValidProvider = Provider<bool>((ref) {
      final emailId = ref.watch(emailIdProvider);
      final emailDomain = ref.watch(emailDomainProvider);
      return emailId.isNotEmpty && emailDomain.isNotEmpty;
    });
    final isAllValid = ref.watch(isAllValidProvider);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "회원가입"),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            context.go('/');
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
              value: 0.16,
              backgroundColor: HowWeatherColor.neutral[200],
              color: HowWeatherColor.primary[900],
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(
              height: 32,
            ),
            Semibold_24px(text: "이메일을 입력해주세요."),
            SizedBox(
              height: 60,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    onChanged: (value) =>
                        ref.read(emailIdProvider.notifier).state = value,
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
                      labelText: "이메일 입력",
                      labelStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: HowWeatherColor.neutral[200],
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Semibold_20px(
                      text: "@",
                      color: HowWeatherColor.neutral[200],
                    )),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    onChanged: (value) =>
                        ref.read(emailDomainProvider.notifier).state = value,
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
                      labelText: "선택",
                      labelStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: HowWeatherColor.neutral[200],
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: bottomSheetWidget(context, isAllValid),
    );
  }

  Widget bottomSheetWidget(BuildContext context, isAllValid) {
    return GestureDetector(
      onTap: isAllValid
          ? () {
              context.go('/signUp/password');
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
