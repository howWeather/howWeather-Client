import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:client/model/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final temperamentProvider = StateProvider<int?>((ref) => null);
final genderProvider = StateProvider<int?>((ref) => null);
final ageProvider = StateProvider<String?>((ref) => null);

final isAllValidProvider = Provider<bool>((ref) {
  final temperament = ref.watch(temperamentProvider);
  final gender = ref.watch(genderProvider);
  final age = ref.watch(ageProvider);
  return temperament != null && gender != null && age != null;
});

class SignUpPersonal extends ConsumerWidget {
  final SignupData signupData;
  SignUpPersonal({super.key, required this.signupData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: 0.8,
                backgroundColor: HowWeatherColor.neutral[200],
                color: HowWeatherColor.primary[900],
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(
                height: 32,
              ),
              Semibold_24px(text: "더욱 효과적인 의상 추천을 위해\n아래 내용에 답변해주세요"),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SvgPicture.asset("assets/icons/cloud.svg"),
                  SizedBox(
                    width: 12,
                  ),
                  Medium_14px(text: "알려주신 내용을 기반으로 AI가 학습을 진행해 의상을\n추천해드립니다!"),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              buildChoiceGroup(
                ref: ref,
                title: "당신은 어떤 체질인가요?",
                options: ["더위를 많이 타요", "평범한 것 같아요", "추위를 많이 타요"],
                provider: temperamentProvider,
                colors: [
                  HowWeatherColor.secondary[800]!,
                  HowWeatherColor.secondary[600]!,
                  HowWeatherColor.primary[900]!,
                ],
              ),
              SizedBox(
                height: 20,
              ),
              buildChoiceGroup(
                ref: ref,
                title: "당신의 성별은 무엇인가요?",
                options: ["여자", "남자"],
                provider: genderProvider,
                colors: [
                  HowWeatherColor.primary[200]!,
                  HowWeatherColor.primary[200]!,
                ],
              ),
              SizedBox(
                height: 20,
              ),
              buildDropdown(
                ref: ref,
                title: "당신의 연령대는 어떻게 되나요?",
                options: ["10대", "20대", "30대 이상"], //TODO: 추후 수정
                provider: ageProvider,
              ),
              SizedBox(
                height: 70,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: bottomSheetWidget(context, ref),
    );
  }

  Widget buildChoiceGroup({
    required WidgetRef ref,
    required String title,
    required List<String> options,
    required StateProvider<int?> provider,
    required List<Color> colors,
  }) {
    final selectedIndex = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semibold_18px(text: title),
        SizedBox(height: 16),
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
                  color: isSelected
                      ? HowWeatherColor.white
                      : HowWeatherColor.black,
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
    required String title,
    required List<String> options,
    required StateProvider<String?> provider,
  }) {
    final selectedValue = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semibold_18px(text: title),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: HowWeatherColor.primary[200]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text("선택하세요", style: TextStyle(color: Colors.grey)),
              items: options.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
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

  Widget bottomSheetWidget(BuildContext context, ref) {
    final isAllValid = ref.watch(isAllValidProvider);
    return GestureDetector(
      onTap: isAllValid
          ? () {
              final updatedData = signupData.copyWith(
                constitution: mapConstitution(ref.read(temperamentProvider)),
                ageGroup: mapAgeGroup(ref.read(ageProvider)),
                gender: mapGender(ref.read(genderProvider)),
              );

              context.push('/signUp/check', extra: updatedData);
              ref.read(temperamentProvider.notifier).state = null;
              ref.read(ageProvider.notifier).state = null;
              ref.read(genderProvider.notifier).state = null;
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

  int? mapConstitution(int? value) {
    // 화면 표시 순서: 더위(0), 보통(1), 추위(2)
    // API 요구: 추위(1), 보통(2), 더위(3)
    switch (value) {
      case 0:
        return 3;
      case 1:
        return 2;
      case 2:
        return 1;
      default:
        return null;
    }
  }

  int? mapAgeGroup(String? value) {
    switch (value) {
      case "10대":
        return 1;
      case "20대":
        return 2;
      case "30대 이상":
        return 3;
      default:
        return null;
    }
  }

  int? mapGender(int? value) {
    switch (value) {
      case 0:
        return 1;
      case 1:
        return 2;
      default:
        return null;
    }
  }
}
