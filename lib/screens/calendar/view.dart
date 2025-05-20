import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final selectedTimeProvider = StateProvider<String?>((ref) => null);

class Calendar extends ConsumerWidget {
  Calendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: HowWeatherColor.white,
        surfaceTintColor: Colors.transparent,
        title: Bold_22px(
          text: "기록 달력",
          color: HowWeatherColor.black,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 34),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: MonthCalendar(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(
                      height: 1,
                      color: HowWeatherColor.primary[900],
                    ),
                  ),
                  DailyHistory(),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final calendarFormatProvider =
      StateProvider<CalendarFormat>((ref) => CalendarFormat.month);
  final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
  final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

  Widget MonthCalendar() {
    // 예시 이벤트 목록 ...TODO: api 연결
    final Map<DateTime, List<String>> events = {
      DateTime.utc(2025, 5, 15): ['Event 1'],
      DateTime.utc(2025, 5, 19): ['Event 1'],
      DateTime.utc(2025, 5, 20): ['Event 2'],
    };

    return Consumer(
      builder: (context, ref, _) {
        final calendarFormat = ref.watch(calendarFormatProvider);
        final focusedDay = ref.watch(focusedDayProvider);
        final selectedDay = ref.watch(selectedDayProvider);

        return Column(
          children: [
            // nnnn년 n월
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              color: HowWeatherColor.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(focusedDayProvider.notifier).state =
                          focusedDay.subtract(Duration(days: 30));
                    },
                    child: SvgPicture.asset(
                      'assets/icons/circle-left.svg',
                      color: HowWeatherColor.neutral[900],
                    ),
                  ),
                  Text(
                    DateFormat('y년 M월', 'ko_KR').format(focusedDay),
                    style: TextStyle(
                      color: HowWeatherColor.neutral[900],
                      fontFamily: 'Pretendard',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(focusedDayProvider.notifier).state =
                          focusedDay.add(Duration(days: 30));
                    },
                    child: SvgPicture.asset(
                      'assets/icons/circle-right.svg',
                      color: HowWeatherColor.neutral[900],
                    ),
                  ),
                ],
              ),
            ),
            // 달력 body
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: HowWeatherColor.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TableCalendar(
                headerVisible: false,
                daysOfWeekHeight: 55,
                // 요일
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) {
                    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                    return weekdays[date.weekday % 7];
                  },
                  weekdayStyle: TextStyle(
                    color: HowWeatherColor.neutral[500],
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: HowWeatherColor.neutral[500],
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // 날짜
                calendarStyle: CalendarStyle(
                  markersAlignment: Alignment.topRight,
                  canMarkersOverflow: true,
                  markersMaxCount: 1,
                  markersAnchor: 0.7,
                  outsideDaysVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  // 일정 있을 경우 마크 표시
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -5,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: HowWeatherColor.secondary[400]!,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Medium_18px(
                                text: '${day.day}',
                                color: HowWeatherColor.black,
                              ),
                            ),
                          ]);
                    }
                    return null;
                  },
                  // 오늘 날짜
                  todayBuilder: (context, day, focusedDay) {
                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Medium_18px(
                            text: '${day.day}',
                            color: HowWeatherColor.black,
                          ),
                        ),
                        Positioned(
                          top: 28,
                          child: Medium_14px(
                            text: '오늘',
                            color: HowWeatherColor.secondary[900],
                          ),
                        ),
                      ],
                    );
                  },
                  // 선택된 날짜
                  selectedBuilder: (context, day, focusedDay) {
                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -5,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HowWeatherColor.secondary[700],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Medium_18px(
                            text: '${day.day}',
                            color: HowWeatherColor.black,
                          ),
                        ),
                      ],
                    );
                  },
                  // 기본 날짜
                  defaultBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Column(
                        children: [
                          Medium_18px(
                            text: '${day.day}',
                            color: HowWeatherColor.black,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // 주간 높이
                rowHeight: 55,
                focusedDay: focusedDay,
                // 달력 시작 날짜
                firstDay: DateTime.utc(DateTime.now().year, 01, 01),
                // 달력 종료 날짜
                lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },
                onDaySelected: (selected, focused) {
                  ref.read(selectedDayProvider.notifier).state = selected;
                  ref.read(focusedDayProvider.notifier).state = focused;

                  if (isSameDay(selected, DateTime.now())) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Consumer(
                          builder: (context, ref, _) =>
                              historyDialog(context, ref),
                        );
                      },
                    );
                  }
                },
                onFormatChanged: (format) {
                  ref.read(calendarFormatProvider.notifier).state = format;
                },
                onPageChanged: (focused) {
                  ref.read(focusedDayProvider.notifier).state = focused;
                },
                calendarFormat: calendarFormat,
                eventLoader: (day) {
                  return events[DateTime.utc(day.year, day.month, day.day)] ??
                      [];
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget DailyHistory() {
    return Consumer(
      builder: (context, ref, _) {
        final selectedDay = ref.watch(selectedDayProvider);
        final displayDate = selectedDay ?? DateTime.now(); // 선택된 날짜가 없으면 오늘 날짜

        String formattedDate =
            DateFormat('y년 M월 d일', 'ko_KR').format(displayDate);

        return Column(
          children: [
            Semibold_16px(text: formattedDate),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Medium_20px(text: "오전"),
                    SizedBox(width: 4),
                    Bold_20px(text: "12°"),
                    SizedBox(width: 8),
                    Bold_20px(
                      text: "추움",
                      color: HowWeatherColor.primary[900],
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Image.asset("assets/images/T-shirts.png"),
                      SizedBox(
                        width: 12,
                      ),
                      Image.asset("assets/images/windbreak.png"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Medium_20px(text: "오후"),
                    SizedBox(width: 4),
                    Bold_20px(text: "26°"),
                    SizedBox(width: 8),
                    Bold_20px(
                      text: "더움",
                      color: HowWeatherColor.secondary[900],
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            HowWeatherColor.colorMap[3]!.withOpacity(0.7),
                            BlendMode.srcATop),
                        child: Image.asset("assets/images/T-shirts.png"),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Image.asset("assets/images/windbreak.png"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Medium_20px(text: "저녁"),
                    SizedBox(width: 4),
                    Bold_20px(text: "22°"),
                    SizedBox(width: 8),
                    Bold_20px(
                      text: "적당",
                      color: HowWeatherColor.secondary[500],
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Image.asset("assets/images/T-shirts.png"),
                      SizedBox(
                        width: 12,
                      ),
                      Image.asset("assets/images/windbreak.png"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget historyDialog(BuildContext context, WidgetRef ref) {
    String? selectedTime = ref.watch(selectedTimeProvider);

    Widget timeButton(String label, String key) {
      final isSelected = selectedTime == key;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            ref.read(selectedTimeProvider.notifier).state = key;
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? HowWeatherColor.primary[400]
                  : HowWeatherColor.white,
              border: Border.all(
                color: HowWeatherColor.neutral[200]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Medium_14px(
                text: label,
                color:
                    isSelected ? HowWeatherColor.white : HowWeatherColor.black,
              ),
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_20px(text: "착장 기록 등록")),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              timeButton("오전", "morning"),
              SizedBox(width: 8),
              timeButton("오후", "afternoon"),
              SizedBox(width: 8),
              timeButton("저녁", "evening"),
            ],
          ),
          SizedBox(height: 12),
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
                    context.pop();
                    context.push('/calendar/register');
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HowWeatherColor.primary[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Medium_14px(
                        text: "등록",
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
}
