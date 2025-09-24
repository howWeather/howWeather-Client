import 'dart:async'; // Timer를 사용하기 위해 import 합니다.

import 'package:client/api/auth/auth_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/toast.dart';
import 'package:client/model/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SignUpEmailCheck extends ConsumerStatefulWidget {
  final SignupData signupData;

  const SignUpEmailCheck({super.key, required this.signupData});

  @override
  ConsumerState<SignUpEmailCheck> createState() => _SignUpEmailCheckState();
}

class _SignUpEmailCheckState extends ConsumerState<SignUpEmailCheck> {
  final verificationCodeProvider = StateProvider<String>((ref) => '');
  final isCodeSentProvider = StateProvider<bool>((ref) => false);
  final isVerificationSuccessProvider = StateProvider<bool>((ref) => false);
  final verificationMessageProvider = StateProvider<String>((ref) => '');

  final timerProvider = StateProvider<int>((ref) => 600); // 10분(600초)으로 초기 설정

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();

    // 타이머 시간 초기화
    ref.read(timerProvider.notifier).state = 600;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ref.read(timerProvider) > 0) {
        ref.read(timerProvider.notifier).state--;
      } else {
        timer.cancel();
      }
    });
  }

  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final localPart = parts[0];
    final domain = parts[1];
    if (localPart.length <= 2) {
      return '${localPart[0]}***@${domain[0]}***.${domain.split('.').last}';
    }
    final maskedLocal =
        '${localPart.substring(0, 2)}${'*' * (localPart.length - 2)}';
    final domainParts = domain.split('.');
    final maskedDomain =
        '${domainParts[0][0]}***${domainParts.length > 1 ? '.${domainParts.last}' : ''}';
    return '$maskedLocal@$maskedDomain';
  }

  String formatTime(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final verificationCode = ref.watch(verificationCodeProvider);
    final isCodeSent = ref.watch(isCodeSentProvider);
    final isVerificationSuccess = ref.watch(isVerificationSuccessProvider);
    final verificationMessage = ref.watch(verificationMessageProvider);

    final remainingTime = ref.watch(timerProvider);
    final isTimerRunning = remainingTime > 0;

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
              onTap: () => context.pop(),
              child: SvgPicture.asset(
                "assets/icons/chevron-left.svg",
                fit: BoxFit.scaleDown,
                height: 20,
                width: 20,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: 0.32,
                    backgroundColor: HowWeatherColor.neutral[200],
                    color: HowWeatherColor.primary[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 32),
                  Semibold_24px(text: "이메일 인증"),
                  const SizedBox(height: 40),
                  Medium_16px(
                    text:
                        '${maskEmail(widget.signupData.email)}로 인증 메일을 전송합니다.',
                    color: HowWeatherColor.primary[900],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final viewModel =
                            ref.read(authViewModelProvider.notifier);
                        final result =
                            await viewModel.requestEmailVerificationCode(
                                widget.signupData.email);
                        ref.read(isCodeSentProvider.notifier).state = true;
                        ref.read(verificationMessageProvider.notifier).state =
                            result;

                        startTimer();

                        HowWeatherToast.show(context, result, false);
                      } catch (e) {
                        HowWeatherToast.show(context, '${e.toString()}', true);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: HowWeatherColor.primary[900]),
                      child: Center(
                        child: Medium_16px(
                          text: isCodeSent ? '인증 메일 재전송' : '인증 요청',
                          color: HowWeatherColor.neutral[50],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Medium_16px(
                      text: '메일 내 인증 코드를 시간 내에 입력해주세요. 인증은 하루 최대 5번까지 가능합니다.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) => ref
                              .read(verificationCodeProvider.notifier)
                              .state = value,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: HowWeatherColor.black),
                          decoration: InputDecoration(
                            suffixIcon: isCodeSent
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Center(
                                      widthFactor: 1.0,
                                      child: Medium_16px(
                                        text: formatTime(remainingTime),
                                        color: isTimerRunning
                                            ? HowWeatherColor.primary[900]
                                            : Colors.red,
                                      ),
                                    ),
                                  )
                                : null,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: HowWeatherColor.neutral[200]!,
                                  width: 2),
                            ),
                            filled: true,
                            fillColor: HowWeatherColor.neutral[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: HowWeatherColor.primary[900]!,
                                  width: 2),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: "6자리 인증코드",
                            labelStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HowWeatherColor.neutral[400],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: verificationCode.length == 6 && isTimerRunning
                            ? () async {
                                try {
                                  final viewModel =
                                      ref.read(authViewModelProvider.notifier);
                                  final result =
                                      await viewModel.verifyEmailCode(
                                          widget.signupData.email,
                                          verificationCode);
                                  ref
                                      .read(isVerificationSuccessProvider
                                          .notifier)
                                      .state = true;
                                  ref
                                      .read(
                                          verificationMessageProvider.notifier)
                                      .state = result;
                                  _timer?.cancel();
                                  HowWeatherToast.show(context, result, false);
                                } catch (e) {
                                  ref
                                      .read(isVerificationSuccessProvider
                                          .notifier)
                                      .state = false;
                                  String errorMessage = e
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                  ref
                                      .read(
                                          verificationMessageProvider.notifier)
                                      .state = errorMessage;

                                  HowWeatherToast.show(
                                      context, errorMessage, true);
                                }
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  verificationCode.length == 6 && isTimerRunning
                                      ? HowWeatherColor.primary[900]
                                      : HowWeatherColor.neutral[200]),
                          child: Center(
                            child: Medium_16px(
                              text: '확인',
                              color:
                                  verificationCode.length == 6 && isTimerRunning
                                      ? HowWeatherColor.white
                                      : HowWeatherColor.neutral[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (verificationMessage.isNotEmpty)
                    Medium_16px(
                      text: verificationMessage,
                      color: isVerificationSuccess
                          ? HowWeatherColor.primary[900]
                          : Colors.red,
                    ),
                  const SizedBox(height: 92),
                ],
              ),
            ),
          ),
          bottomSheet: bottomSheetWidget(context, isVerificationSuccess),
        ),
      ),
    );
  }

  Widget bottomSheetWidget(BuildContext context, bool isVerificationSuccess) {
    return GestureDetector(
      onTap: isVerificationSuccess
          ? () {
              context.push('/signUp/id', extra: widget.signupData);
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: HowWeatherColor.white,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isVerificationSuccess
                ? HowWeatherColor.primary[900]
                : HowWeatherColor.neutral[200],
          ),
          child: Center(
            child: Semibold_18px(
              text: "다음",
              color: isVerificationSuccess
                  ? HowWeatherColor.white
                  : HowWeatherColor.neutral[400],
            ),
          ),
        ),
      ),
    );
  }
}
