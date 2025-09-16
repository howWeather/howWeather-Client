import 'package:client/api/weather/weather_repository.dart';
import 'package:client/api/weather/weather_view_model.dart';
import 'package:client/main.dart';
import 'package:client/model/weather.dart';
import 'package:client/service/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/api/model/model_view_model.dart';
import 'package:client/api/cloth/cloth_view_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

final container = ProviderContainer();

// 날씨와 옷 정보를 모두 업데이트하는 통합 함수
Future<void> updateHomeWidgetWithAllData() async {
  try {
    print('🔍 위젯 전체 데이터 업데이트 시작');

    // 1. 위치 정보 가져오기
    final locationService = LocationService();
    bool isLocationAvailable = await locationService.isLocationAvailable();

    if (!isLocationAvailable) {
      print('⚠️ 위치 권한이 없습니다. 기본값으로 업데이트합니다.');
      // 기본값 설정 로직 (필요 시)
      return;
    }
    final Position position = await locationService.getCurrentLocation();

    // 2. 날씨 정보 가져오기 및 저장
    final repo = WeatherRepository(apiKey: apiKey);
    final Weather weather = await repo.fetchWeatherByLocation(
        position.latitude, position.longitude);

    await HomeWidget.saveWidgetData<String>(
        'widget_temp', weather.temperature.toStringAsFixed(0));
    await HomeWidget.saveWidgetData<String>('widget_icon', weather.icon);
    await HomeWidget.saveWidgetData<String>('widget_location', weather.name);
    await HomeWidget.saveWidgetData<String>(
        'widget_description', weather.description);
    print('💾 날씨 데이터 저장 완료');

    // 3. 옷 추천 정보 가져오기 및 저장
    // 3.1. 먼저 데이터를 가져오라고 '명령'하고 완료될 때까지 기다립니다.
    await container.read(modelViewModelProvider.notifier).fetchRecommendation();

    // 3.2. 데이터 로드가 완료된 후, provider의 현재 '상태'를 읽어옵니다.
    final modelState = container.read(modelViewModelProvider);
    String upperUrl = '';
    String outerUrl = '';

    // 3.3. 상태가 AsyncData(성공적으로 데이터 로드됨)인지 확인하고 데이터를 추출합니다.
    if (modelState is AsyncData) {
      final recommendations =
          modelState.value; // AsyncData에서 실제 데이터 리스트를 가져옵니다.
      if (recommendations != null && recommendations.isNotEmpty) {
        // 아우터가 있는 추천을 찾기 위해 모든 추천을 확인
        var selectedRecommendation = recommendations.first; // 기본값으로 첫 번째 사용

        // 아우터가 있는 추천이 있다면 그것을 사용
        for (var rec in recommendations) {
          if (rec.outersTypeList.isNotEmpty) {
            selectedRecommendation = rec;
            print('🧥 아우터가 있는 추천을 발견했습니다: ${rec.outersTypeList}');
            break;
          }
        }

        // 선택된 추천에서 상의 URL 가져오기
        if (selectedRecommendation.uppersTypeList.isNotEmpty) {
          final upperType = selectedRecommendation.uppersTypeList.first;
          // .future를 사용하여 Provider의 Future 결과를 기다립니다.
          upperUrl =
              await container.read(upperClothImageProvider(upperType).future);
        }

        // 선택된 추천에서 아우터 URL 가져오기
        if (selectedRecommendation.outersTypeList.isNotEmpty) {
          final outerType = selectedRecommendation.outersTypeList.first;
          outerUrl =
              await container.read(outerClothImageProvider(outerType).future);
          print('🧥 아우터 URL 가져옴: $outerUrl');
        } else {
          print('🚫 선택된 추천에 아우터가 없습니다');
        }
      }
    }

    await HomeWidget.saveWidgetData<String>('widget_upper_url', upperUrl);
    await HomeWidget.saveWidgetData<String>('widget_outer_url', outerUrl);
    print('💾 옷 추천 데이터 저장 완료: 상의=$upperUrl, 아우터=$outerUrl');

    // 4. 위젯 업데이트 요청
    await HomeWidget.updateWidget(
      name: 'WeatherHomeWidgetProvider',
      androidName: 'WeatherHomeWidgetProvider',
      qualifiedAndroidName: 'com.howweather.client.WeatherHomeWidgetProvider',
    );

    print('✅ 위젯 전체 데이터 업데이트 완료');
  } catch (e) {
    print('❌ 홈 위젯 업데이트 실패: $e');
  }
}

// 백그라운드 콜백은 통합 함수를 호출
void backgroundCallback(Uri? uri) async {
  print('🏠 HomeWidget 백그라운드 콜백 실행');

  if (uri != null) {
    if (uri.path == "/") {
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState?.pushNamed('/home');
      });
    }
  }

  await updateHomeWidgetWithAllData();
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("⏰ 백그라운드 작업 실행: $task");

    await updateHomeWidgetWithAllData();
    return Future.value(true);
  });
}
