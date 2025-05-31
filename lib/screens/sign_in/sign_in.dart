import 'package:client/api/alarm/alarm_repository.dart';
import 'package:client/api/auth/auth_view_model.dart';
import 'package:client/api/oauth2/oauth2_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignSplashState();
}

class _SignSplashState extends ConsumerState<SignIn> {
  final idProvider = StateProvider<String>((ref) => '');
  final passwordProvider = StateProvider<String>((ref) => '');
  final obscureProvider = StateProvider<bool>((ref) => true);
  final isPasswordFocusedProvider = StateProvider<bool>((ref) => false);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isAllValidProvider = Provider<bool>((ref) {
      final id = ref.watch(idProvider);
      final password = ref.watch(passwordProvider);
      return id.isNotEmpty && password.isNotEmpty;
    });
    final isAllValid = ref.watch(isAllValidProvider);

    return Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: HowWeatherColor.primary[700],
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1), // 여유공간
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                style: TextStyle(
                  color: HowWeatherColor.white,
                  fontFamily: "BagelFatOne",
                  fontSize: 42,
                ),
                "날씨어때",
              ),
              Medium_16px(
                text: "체감 온도 학습 기반 개인화 의상 추천 서비스",
                color: HowWeatherColor.white,
              ),
              SizedBox(
                height: 24,
              ),
              IdTextField(ref),
              SizedBox(
                height: 8,
              ),
              PasswordTextField(ref),
              SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: isAllValid
                    ? () async {
                        final username = ref.read(idProvider);
                        final password = ref.read(passwordProvider);
                        final authViewModel =
                            ref.read(authViewModelProvider.notifier);

                        await authViewModel.login(username, password);

                        final loginState = ref.read(authViewModelProvider);
                        if (loginState is AsyncData) {
                          await AlarmRepository().saveFCMToken();
                          context.go('/home');
                        } else if (loginState is AsyncError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('로그인 실패: ${loginState.error}')),
                          );
                        }
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: HowWeatherColor.secondary[500],
                  ),
                  child: Center(
                    child: Bold_22px(
                      text: "로그인",
                      color: HowWeatherColor.neutral[50],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      context.push('/signUp/email');
                    },
                    child: Medium_18px(
                      text: "회원가입",
                      color: HowWeatherColor.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.push('/signIn/findPassword');
                    },
                    child: Medium_18px(
                      text: "비밀번호 찾기",
                      color: HowWeatherColor.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: HowWeatherColor.neutral[50],
                      height: 1,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Medium_16px(
                      text: "SNS계정으로 로그인",
                      color: HowWeatherColor.neutral[50],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: HowWeatherColor.neutral[50],
                      height: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () async {
                        kakaoSignIn();
                      },
                      child: SvgPicture.asset("assets/icons/kakao-icon.svg")),
                  SizedBox(
                    width: 24,
                  ),
                  SvgPicture.asset("assets/icons/google-icon.svg"),
                ],
              ),
              SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void kakaoSignIn() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }

    fetchSocialLogin();
  }

  Future<void> fetchSocialLogin() async {
    final oauth2ViewModel = ref.read(oauth2ViewModelProvider.notifier);

    await oauth2ViewModel.loginKakao();

    final loginState = ref.read(oauth2ViewModelProvider);
    if (loginState is AsyncData) {
      await AlarmRepository().saveFCMToken();
      context.go('/home');
    } else if (loginState is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소셜 로그인 실패: ${loginState.error}')),
      );
    }
  }

  Widget IdTextField(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onChanged: (value) => ref.read(idProvider.notifier).state = value,
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
            labelText: "아이디 입력",
            labelStyle: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HowWeatherColor.neutral[300],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 19),
          ),
        ),
      ],
    );
  }

  Widget PasswordTextField(WidgetRef ref) {
    final isObscure = ref.watch(obscureProvider);
    final isFocused = ref.watch(isPasswordFocusedProvider);
    final password = ref.watch(passwordProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            ref.read(isPasswordFocusedProvider.notifier).state = hasFocus;
          },
          child: TextFormField(
            onChanged: (value) =>
                ref.read(passwordProvider.notifier).state = value,
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
                borderSide:
                    BorderSide(color: HowWeatherColor.neutral[100]!, width: 3),
              ),
              filled: true,
              fillColor: HowWeatherColor.neutral[50],
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: HowWeatherColor.neutral[300]!, width: 3),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: "비밀번호 입력",
              labelStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: HowWeatherColor.neutral[300],
              ),
              suffixIcon: (isFocused || password.isNotEmpty)
                  ? IconButton(
                      onPressed: () {
                        ref.read(obscureProvider.notifier).state =
                            !ref.read(obscureProvider);
                      },
                      icon: SvgPicture.asset(
                        isObscure
                            ? "assets/icons/eye-slash.svg"
                            : "assets/icons/eye-open.svg",
                      ),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
            ),
          ),
        ),
      ],
    );
  }
}
