import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final nicknameProvider = StateProvider<String>((ref) => '');
final temperamentProvider = StateProvider<int?>((ref) => null);
final genderProvider = StateProvider<int?>((ref) => null);
final ageProvider = StateProvider<String?>((ref) => null);

class Profile extends ConsumerWidget {
  Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "프로필"),
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
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleCard(context, ref, "닉네임", "닉네임 변경", changeNickname(ref)),
            ContainerCard("test"),
            SizedBox(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Medium_18px(text: "이메일"),
            ),
            Row(
              children: [
                Expanded(flex: 2, child: ContainerCard("test")),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Medium_18px(
                    text: "@",
                    color: HowWeatherColor.neutral[200],
                  ),
                ),
                Expanded(flex: 1, child: ContainerCard("test.com")),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Medium_18px(text: "아이디"),
            ),
            ContainerCard("testid"),
            SizedBox(
              height: 8,
            ),
            titleCard(context, ref, "체질", "체질 변경", changeTemperament(ref)),
            ContainerCard("평범한 것 같아요"),
            SizedBox(
              height: 8,
            ),
            titleCard(context, ref, "성별", "성별 변경", changeGender(ref)),
            ContainerCard("여"),
            SizedBox(
              height: 8,
            ),
            titleCard(context, ref, "나이", "나이 변경", changeAge(ref)),
            ContainerCard("10대"),
          ],
        ),
      ),
    );
  }

  Widget titleCard(
      BuildContext context, WidgetRef ref, text, title, Widget widget) {
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
                  return changeDialog(context, ref, title, widget);
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
      BuildContext context, WidgetRef ref, title, Widget widget) {
    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(
        child: Semibold_20px(text: title),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget,
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
                  onTap: () {
                    context.push('/mypage/profile');
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
      ),
    );
  }

  Widget changeNickname(WidgetRef ref) {
    return TextFormField(
      onChanged: (value) {
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

  Widget changeTemperament(ref) {
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

  Widget changeGender(ref) {
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

  Widget changeAge(ref) {
    return buildDropdown(
      ref: ref,
      options: ["10대", "20대", "30대 이상"],
      provider: ageProvider,
    );
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
    required List<String> options,
    required StateProvider<String?> provider,
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
}
