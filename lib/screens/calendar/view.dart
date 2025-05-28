import 'package:client/api/record/record_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/screens/today_weather/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final selectedTimeProvider = StateProvider<int?>((ref) => null);
final calendarFormatProvider =
    StateProvider<CalendarFormat>((ref) => CalendarFormat.month);
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

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

  Widget MonthCalendar() {
    Map<DateTime, List<String>> generateEvents(
        DateTime month, List<int> recordedDays) {
      return {
        for (var day in recordedDays)
          DateTime.utc(month.year, month.month, day): ['기록됨']
      };
    }

    return Consumer(
      builder: (context, ref, _) {
        final calendarFormat = ref.watch(calendarFormatProvider);
        final focusedDay = ref.watch(focusedDayProvider);
        final selectedDay = ref.watch(selectedDayProvider);
        final monthString = DateFormat('yyyy-MM').format(focusedDay);
        final weatherAsync = ref.watch(weatherByLocationProvider);

        final recordedDaysAsync = ref.watch(recordedDaysProvider(monthString));

        // temperature는 날씨 API에서 가져옴
        final similarDaysAsync = weatherAsync.when(
          data: (weather) => ref.watch(similarDaysProvider(
            (month: monthString, temperature: weather.temperature),
          )),
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
        );

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
              child: recordedDaysAsync.when(
                data: (recordedDays) {
                  return similarDaysAsync.when(
                    data: (similarDays) {
                      Map<DateTime, List<String>> events = {};

                      recordedDaysAsync.whenData((recordedDays) {
                        for (final day in recordedDays) {
                          final date = DateTime.utc(
                              focusedDay.year, focusedDay.month, day);
                          events[date] = ['record'];
                        }
                      });

                      similarDaysAsync.whenData((similarDays) {
                        for (final day in similarDays) {
                          final date = DateTime.utc(
                              focusedDay.year, focusedDay.month, day);
                          events.update(
                            date,
                            (existing) => [...existing, 'similar'],
                            ifAbsent: () => ['similar'],
                          );
                        }
                      });
                      return TableCalendar(
                        headerVisible: false,
                        daysOfWeekHeight: 55,
                        // 요일
                        daysOfWeekStyle: DaysOfWeekStyle(
                          dowTextFormatter: (date, locale) {
                            const weekdays = [
                              '일',
                              '월',
                              '화',
                              '수',
                              '목',
                              '금',
                              '토'
                            ];
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
                              final hasRecord = events.contains('record');
                              final hasSimilar = events.contains('similar');

                              return Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  if (hasSimilar)
                                    Positioned(
                                      top: -7,
                                      child: Container(
                                        width: 39,
                                        height: 39,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                HowWeatherColor.primary[400]!,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (hasRecord)
                                    Positioned(
                                      top: -5,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                HowWeatherColor.secondary[400]!,
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
                                ],
                              );
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
                          ref.read(selectedDayProvider.notifier).state =
                              selected;
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
                          ref.read(calendarFormatProvider.notifier).state =
                              format;
                        },
                        onPageChanged: (focused) {
                          ref.read(focusedDayProvider.notifier).state = focused;
                        },
                        calendarFormat: calendarFormat,
                        eventLoader: (day) {
                          return events[
                                  DateTime.utc(day.year, day.month, day.day)] ??
                              [];
                        },
                      );
                    },
                    loading: () => CircularProgressIndicator(),
                    error: (e, _) => Text('유사 날짜 오류: $e'),
                  );
                },
                loading: () => CircularProgressIndicator(),
                error: (e, _) => Text("에러: $e"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget historyDialog(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTimeProvider);

    Widget timeButton(String label, int value, WidgetRef ref) {
      final isSelected = selected == value;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            ref.read(selectedTimeProvider.notifier).state = value;
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
              timeButton("오전", 1, ref),
              SizedBox(width: 8),
              timeButton("오후", 2, ref),
              SizedBox(width: 8),
              timeButton("저녁", 3, ref),
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

String timeSlotToText(int slot) {
  switch (slot) {
    case 1:
      return "오전";
    case 2:
      return "오후";
    case 3:
      return "저녁";
    default:
      return "시간대 정보 없음";
  }
}

String feelingToText(int feeling) {
  switch (feeling) {
    case 1:
      return "추움";
    case 2:
      return "적당";
    case 3:
      return "더움";
    default:
      return "알 수 없음";
  }
}

Color feelingToColor(int feeling) {
  switch (feeling) {
    case 1:
      return HowWeatherColor.primary[900]!;
    case 2:
      return HowWeatherColor.secondary[500]!;
    case 3:
      return HowWeatherColor.secondary[900]!;
    default:
      return Colors.black;
  }
}

class DailyHistory extends StatefulWidget {
  @override
  State<DailyHistory> createState() => _DailyHistoryState();
}

class _DailyHistoryState extends State<DailyHistory> {
  String? _lastFetchedDate;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final selectedDay = ref.watch(selectedDayProvider);
        final displayDate = selectedDay ?? DateTime.now();

        final formattedDate =
            DateFormat('y년 M월 d일', 'ko_KR').format(displayDate);
        final formattedDate2 = DateFormat('yyyy-MM-dd').format(displayDate);

        final recordState = ref.watch(recordViewModelProvider);
        final recordViewModel = ref.read(recordViewModelProvider.notifier);

        // 날짜가 바뀔 때만 fetch
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lastFetchedDate != formattedDate2) {
            _lastFetchedDate = formattedDate2;
            recordViewModel.fetchRecordByDate(formattedDate2);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semibold_16px(text: formattedDate),
            SizedBox(height: 20),
            recordState.when(
              data: (records) {
                if (records == null || records.isEmpty) {
                  return Center(
                    child: const Bold_20px(text: "기록이 없습니다."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Medium_20px(
                                  text: timeSlotToText(record['timeSlot'])),
                              SizedBox(width: 4),
                              Bold_20px(
                                  text: "${record['temperature'].round()}°"),
                              SizedBox(width: 8),
                              Bold_20px(
                                text: feelingToText(record['feeling']),
                                color: feelingToColor(record['feeling']),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                ...record['uppers'].map<Widget>((id) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Image.asset(
                                        'assets/images/windbreak.png'),
                                  );
                                }).toList(),
                                ...record['outers'].map<Widget>((id) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Image.asset(
                                        'assets/images/windbreak.png'),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("에러: $err")),
            ),
          ],
        );
      },
    );
  }
}
