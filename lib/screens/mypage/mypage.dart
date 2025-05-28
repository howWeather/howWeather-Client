import 'package:client/api/alarm/alarm_repository.dart';
import 'package:client/api/auth/auth_repository.dart';
import 'package:client/api/mypage/mypage_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_dialog.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await ref.read(mypageViewModelProvider.notifier).loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(mypageViewModelProvider);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: HowWeatherColor.white,
        surfaceTintColor: Colors.transparent,
        title: Bold_22px(
          text: "마이페이지",
          color: HowWeatherColor.black,
        ),
        centerTitle: true,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  await context.push('/mypage/profile');
                  ref.read(mypageViewModelProvider.notifier).loadProfile();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    profileState.when(
                      data: (profile) =>
                          Semibold_24px(text: profile?.nickname ?? "닉네임 없음"),
                      loading: () => const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (error, _) => Text("에러"),
                    ),
                    SvgPicture.asset("assets/icons/chevron-right.svg"),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  color: HowWeatherColor.primary[900],
                  height: 1,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset("assets/icons/closet.svg"),
                  SizedBox(
                    width: 8,
                  ),
                  Semibold_20px(text: "나의 옷장"),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  context.push('/mypage/clothes/view');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "의류 조회",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {
                  context.push('/mypage/clothes/delete');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "의류 삭제",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {
                  context.push('/mypage/clothes/enroll');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "의류 등록",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  color: HowWeatherColor.primary[900],
                  height: 1,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset("assets/icons/setting.svg"),
                  SizedBox(
                    width: 8,
                  ),
                  Semibold_20px(text: "설정"),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  context.push('/mypage/notification');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "알림 설정",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {
                  context.push('/mypage/version');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "버전 정보",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {
                  context.push('/mypage/changePassword');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "비밀번호 변경",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => HowWeatherDialog(
                      titleText: "로그아웃",
                      contentText: "로그아웃하시겠습니까?",
                      done: () async {
                        await AlarmRepository().deleteFCMToken();
                        await AuthRepository().logout();
                        context.go('/');
                      },
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "로그아웃",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
              Divider(
                color: HowWeatherColor.neutral[200],
                height: 1,
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => HowWeatherDialog(
                      titleText: "탈퇴",
                      contentText: "탈퇴하시겠습니까?\n모든 기록이 사라집니다.",
                      done: () async {
                        await AuthRepository().withdraw();
                        context.go('/');
                      },
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Medium_18px(
                    text: "탈퇴",
                    color: HowWeatherColor.neutral[600],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
