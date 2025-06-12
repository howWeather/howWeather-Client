import 'package:client/api/closet/closet_view_model.dart';
import 'package:client/api/cloth/cloth_view_model.dart';
import 'package:client/api/record/record_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:client/screens/skeleton/calendar_skeleton.dart';
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

    // 모든 비동기 데이터가 로딩 중인지 체크
    final isLoading = weatherAsync.isLoading ||
        recordedDaysAsync.isLoading ||
        similarDaysAsync.isLoading;

    if (isLoading) {
      return CalendarSkeleton();
    }
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

                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final yesterday =
                              DateTime(now.year, now.month, now.day - 1);
                          final selectedDate = DateTime(
                              selected.year, selected.month, selected.day);

                          // 새벽 5시 30분 이전인지 확인
                          final isBeforeEarlyMorning = now.hour < 5 ||
                              (now.hour == 5 && now.minute < 30);

                          // 오늘 날짜 선택 또는 어제 날짜를 새벽 5시 30분 이전에 선택한 경우 다이얼로그 표시
                          final shouldShowDialog =
                              (selectedDate.isAtSameMomentAs(today)) ||
                                  (selectedDate.isAtSameMomentAs(yesterday) &&
                                      isBeforeEarlyMorning);

                          if (shouldShowDialog) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Consumer(
                                  builder: (context, ref, _) =>
                                      historyDialog(context, ref),
                                );
                              },
                            ).then((_) {
                              ref.read(selectedTimeProvider.notifier).state =
                                  null;
                            });
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
    final selectedDay = ref.watch(selectedDayProvider);
    final now = DateTime.now();

    // 선택된 날짜가 어제인지 확인
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isYesterday = selectedDay != null &&
        selectedDay.year == yesterday.year &&
        selectedDay.month == yesterday.month &&
        selectedDay.day == yesterday.day;

    // 새벽 5시 30분 이전인지 확인
    final isBeforeEarlyMorning =
        now.hour < 5 || (now.hour == 5 && now.minute < 30);

    // 전날 기록 가능 여부
    final canRecordYesterday = isYesterday && isBeforeEarlyMorning;

    // 오늘 날짜의 시간 제한 조건
    final isTodaySelected = selectedDay != null &&
        selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;

    final isMorningEnabled =
        canRecordYesterday || (isTodaySelected && now.hour >= 9);
    final isAfternoonEnabled =
        canRecordYesterday || (isTodaySelected && now.hour >= 14);
    final isEveningEnabled =
        canRecordYesterday || (isTodaySelected && now.hour >= 20);

    Widget timeButton(String label, int value, bool isEnabled, WidgetRef ref) {
      final isSelected = selected == value;

      return Expanded(
        child: GestureDetector(
          onTap: isEnabled
              ? () {
                  ref.read(selectedTimeProvider.notifier).state = value;
                }
              : null,
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
                color: isEnabled
                    ? (isSelected
                        ? HowWeatherColor.white
                        : HowWeatherColor.black)
                    : HowWeatherColor.neutral[300],
              ),
            ),
          ),
        ),
      );
    }

    final isRegisterEnabled = selected != null;

    // 다이얼로그 제목 설정
    String dialogTitle = "착장 기록 등록";
    if (canRecordYesterday) {
      dialogTitle = "전날 착장 기록 등록";
    }

    return AlertDialog(
      backgroundColor: HowWeatherColor.white,
      title: Center(child: Semibold_20px(text: dialogTitle)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              timeButton("오전", 1, isMorningEnabled, ref),
              SizedBox(width: 8),
              timeButton("오후", 2, isAfternoonEnabled, ref),
              SizedBox(width: 8),
              timeButton("저녁", 3, isEveningEnabled, ref),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 8),
          // 안내 문구
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (canRecordYesterday) ...[
                Medium_14px(
                  text: "• 전날 기록을 작성하고 있습니다.",
                  color: HowWeatherColor.secondary[700],
                ),
                Medium_14px(text: "• 새벽 5시 30분 이전까지 작성 가능합니다."),
              ] else ...[
                Medium_14px(text: "• 전날의 기록은 다음 날 새벽 5시 30분 이전에 작성 가능합니다."),
                Medium_14px(text: "• 오늘의 기록은 해당 시간대 이후에 작성 가능합니다."),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Medium_14px(text: "- 오전 : 9시 이후"),
                      Medium_14px(text: "- 오후 : 14시 이후"),
                      Medium_14px(text: "- 저녁 : 20시 이후"),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                    ref.read(selectedTimeProvider.notifier).state = null;
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HowWeatherColor.neutral[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: HowWeatherColor.neutral[200]!, width: 2),
                    ),
                    child: Center(
                        child: Medium_14px(
                      text: "취소",
                      color: HowWeatherColor.neutral[700],
                    )),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: isRegisterEnabled
                      ? () {
                          context.push('/calendar/register');
                          ref.read(closetProvider.notifier).loadClothes();
                        }
                      : null,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRegisterEnabled
                          ? HowWeatherColor.primary[900]
                          : HowWeatherColor.neutral[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isRegisterEnabled
                              ? HowWeatherColor.primary[900]!
                              : HowWeatherColor.neutral[200]!,
                          width: 2),
                    ),
                    child: Center(
                      child: Medium_14px(
                        text: "등록",
                        color: isRegisterEnabled
                            ? HowWeatherColor.white
                            : HowWeatherColor.neutral[500],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽 정보 섹션
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Medium_20px(
                                      text: timeSlotToText(record['timeSlot'])),
                                  SizedBox(width: 4),
                                  Bold_20px(
                                      text:
                                          "${record['temperature'].round()}°"),
                                ],
                              ),
                              SizedBox(height: 4),
                              Bold_20px(
                                text: feelingToText(record['feeling']),
                                color: feelingToColor(record['feeling']),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          // 오른쪽 착장 섹션 - Flexible로 감싸서 오버플로우 방지
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...record['uppers'].map<Widget>((id) {
                                      final color = HowWeatherColor
                                              .colorMap[id['color']] ??
                                          Colors.transparent;

                                      final matrix = HowWeatherColor
                                          .createColorMatrixFromColor(color);

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: FutureBuilder<String>(
                                          future: ref
                                              .read(clothViewModelProvider
                                                  .notifier)
                                              .getUpperClothImage(
                                                  id['clothType']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const SizedBox(
                                                width: 50,
                                                height: 50,
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return const SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Icon(Icons.error),
                                              );
                                            } else if (snapshot.hasData) {
                                              return ColorFiltered(
                                                colorFilter:
                                                    ColorFilter.matrix(matrix),
                                                child: Image.network(
                                                  snapshot.data!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                      );
                                    }).toList(),
                                    ...record['outers'].map<Widget>((id) {
                                      final color = HowWeatherColor
                                              .colorMap[id['color']] ??
                                          Colors.transparent;

                                      final matrix = HowWeatherColor
                                          .createColorMatrixFromColor(color);

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: FutureBuilder<String>(
                                          future: ref
                                              .read(clothViewModelProvider
                                                  .notifier)
                                              .getOuterClothImage(
                                                  id['clothType']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Icon(Icons.error),
                                              );
                                            } else if (snapshot.hasData) {
                                              return ColorFiltered(
                                                colorFilter:
                                                    ColorFilter.matrix(matrix),
                                                child: Image.network(
                                                  snapshot.data!,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
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
