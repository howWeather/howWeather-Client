import 'package:client/api/mypage/mypage_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final nicknameProvider = StateProvider<String>((ref) => '');
final temperamentProvider = StateProvider<int?>((ref) => null);
final genderProvider = StateProvider<int?>((ref) => null);
final ageProvider = StateProvider<int?>((ref) => null);

class Profile extends ConsumerWidget {
  Profile({super.key});

  final List<String> temperamentOptions = [
    "더위를 많이 타요",
    "평범한 것 같아요",
    "추위를 많이 타요"
  ];
  final List<String> genderOptions = ["여자", "남자"];
  final List<String> ageOptions = ["10대", "20대", "30대 이상"];

  String? getEmailFront(String? email) {
    if (email == null || !email.contains("@")) return email;
    return email.split("@")[0];
  }

  String? getEmailBack(String? email) {
    if (email == null || !email.contains("@")) return "";
    return email.split("@")[1];
  }

  String? getTemperamentText(int? index) {
    if (index == null || index < 1 || index > temperamentOptions.length)
      return null;
    return temperamentOptions[index - 1];
  }

  String? getGenderText(int? index) {
    if (index == null || index < 1 || index > genderOptions.length) return null;
    return genderOptions[index - 1];
  }

  String? getAgeText(int? index) {
    if (index == null || index < 1 || index > ageOptions.length) return null;
    return ageOptions[index - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(mypageViewModelProvider);

    // 다이얼로그가 처음 열릴 때 초기값 설정
    profileState.when(
      data: (profile) {
        if (profile != null) {
          // 다이얼로그를 열 때 초기값 설정을 위해 필요한 데이터 초기화
          Future.microtask(() {
            if (profile.nickname != null) {
              ref.read(nicknameProvider.notifier).state =
                  profile.nickname ?? '';
            }
            if (profile.constitution != null) {
              ref.read(temperamentProvider.notifier).state =
                  profile.constitution! - 1;
            }
            if (profile.gender != null) {
              ref.read(genderProvider.notifier).state = profile.gender! - 1;
            }
            if (profile.ageGroup != null) {
              ref.read(ageProvider.notifier).state = profile.ageGroup;
            }
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "프로필"),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            context.go('/mypage');
          },
          child: SvgPicture.asset(
            "assets/icons/chevron-left.svg",
            fit: BoxFit.scaleDown,
            height: 20,
            width: 20,
          ),
        ),
      ),
      body: profileState.when(
        data: (profile) => Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleCard(
                context,
                ref,
                "닉네임",
                "닉네임 변경",
                (setState) => changeNickname(ref),
                () async {
                  final viewModel = ref.read(mypageViewModelProvider.notifier);
                  final value = ref.read(nicknameProvider);
                  await viewModel.updateNickname(value);
                  // 프로필 상태 새로고침
                  ref.invalidate(mypageViewModelProvider);
                },
              ),
              ContainerCard(profile?.nickname),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Medium_18px(text: "이메일"),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: ContainerCard(getEmailFront(profile?.email))),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Medium_18px(
                      text: "@",
                      color: HowWeatherColor.neutral[200],
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: ContainerCard(getEmailBack(profile?.email))),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Medium_18px(text: "아이디"),
              ),
              ContainerCard(profile?.loginId),
              SizedBox(
                height: 8,
              ),
              titleCard(
                context,
                ref,
                "체질",
                "체질 변경",
                (setState) => changeTemperament(),
                () async {
                  final viewModel = ref.read(mypageViewModelProvider.notifier);
                  final value = ref.read(temperamentProvider.notifier).state;
                  await viewModel
                      .updateConstitution(value! + 1); // 1부터 시작하므로 +1 추가
                  // 프로필 상태 새로고침
                  ref.invalidate(mypageViewModelProvider);
                },
              ),
              ContainerCard(getTemperamentText(profile?.constitution)),
              SizedBox(
                height: 8,
              ),
              titleCard(
                context,
                ref,
                "성별",
                "성별 변경",
                (setState) => changeGender(),
                () async {
                  final viewModel = ref.read(mypageViewModelProvider.notifier);
                  final value = ref.read(genderProvider.notifier).state;
                  await viewModel.updateGender(value! + 1); // 1부터 시작하므로 +1 추가
                  // 프로필 상태 새로고침
                  ref.invalidate(mypageViewModelProvider);
                },
              ),
              ContainerCard(getGenderText(profile?.gender)),
              SizedBox(
                height: 8,
              ),
              titleCard(
                context,
                ref,
                "나이",
                "나이 변경",
                (setState) => changeAge(),
                () async {
                  final viewModel = ref.read(mypageViewModelProvider.notifier);
                  final value = ref.read(ageProvider.notifier).state;
                  await viewModel.updateAge(value!);
                  // 프로필 상태 새로고침
                  ref.invalidate(mypageViewModelProvider);
                },
              ),
              ContainerCard(getAgeText(profile?.ageGroup)),
            ],
          ),
        ),
        loading: () => Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, _) => Center(child: Text("에러가 발생했습니다: $error")),
      ),
    );
  }

  Widget titleCard(
    BuildContext context,
    WidgetRef ref,
    text,
    title,
    Widget Function(StateSetter setState) builder,
    Future<void> Function() onConfirm,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Medium_18px(text: text),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return changeDialog(context, ref, title, builder, onConfirm);
                },
              );
            },
            child: Medium_18px(
              text: "변경",
              color: HowWeatherColor.primary[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget ContainerCard(text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: HowWeatherColor.neutral[100]!, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Medium_16px(text: text),
    );
  }

  Widget changeDialog(
    BuildContext context,
    WidgetRef ref,
    title,
    Widget Function(StateSetter setState) builder,
    Future<void> Function() onConfirm,
  ) {
    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(
        child: Semibold_20px(text: title),
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              builder(setState),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: HowWeatherColor.neutral[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Medium_14px(text: "취소")),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (!TapThrottler.canTap('profile_change')) return;
                        Navigator.pop(context); // 다이얼로그를 먼저 닫음
                        await onConfirm(); // 업데이트 함수 실행
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: HowWeatherColor.primary[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Medium_14px(
                            text: "변경",
                            color: HowWeatherColor.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget changeNickname(WidgetRef ref) {
    return TextFormField(
      onChanged: (value) async {
        ref.read(nicknameProvider.notifier).state = value;
      },
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
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class changeTemperament extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildChoiceGroup(
      ref: ref,
      options: ["더위를 많이 타요", "평범한 것 같아요", "추위를 많이 타요"],
      provider: temperamentProvider,
      colors: [
        HowWeatherColor.secondary[800]!,
        HowWeatherColor.secondary[600]!,
        HowWeatherColor.primary[900]!,
      ],
    );
  }
}

class changeGender extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildChoiceGroup(
      ref: ref,
      options: ["여자", "남자"],
      provider: genderProvider,
      colors: [
        HowWeatherColor.primary[200]!,
        HowWeatherColor.primary[200]!,
      ],
    );
  }
}

final ageDisplayMap = {
  1: "10대",
  2: "20대",
  3: "30대 이상",
};

class changeAge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildDropdown(
      ref: ref,
      options: [1, 2, 3],
      provider: ageProvider,
      displayMap: ageDisplayMap,
    );
  }
}

Widget buildChoiceGroup({
  required WidgetRef ref,
  required List<String> options,
  required StateProvider<int?> provider,
  required List<Color> colors,
}) {
  final selectedIndex = ref.watch(provider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...List.generate(options.length, (index) {
        final isSelected = selectedIndex == index;
        final color = colors[index];
        return InkWell(
          onTap: () {
            ref.read(provider.notifier).state = index;
          },
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            margin: EdgeInsets.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              border: Border.all(width: 2, color: color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Medium_16px(
                text: options[index],
                color:
                    isSelected ? HowWeatherColor.white : HowWeatherColor.black,
              ),
            ),
          ),
        );
      }),
    ],
  );
}

Widget buildDropdown({
  required WidgetRef ref,
  required List<int> options,
  required StateProvider<int?> provider,
  required Map<int, String> displayMap,
}) {
  final selectedValue = ref.watch(provider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: HowWeatherColor.primary[200]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selectedValue,
            hint: Text("선택하세요", style: TextStyle(color: Colors.grey)),
            isExpanded: true,
            items: options.map((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(displayMap[value]!),
              );
            }).toList(),
            onChanged: (newValue) {
              ref.read(provider.notifier).state = newValue;
            },
          ),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
