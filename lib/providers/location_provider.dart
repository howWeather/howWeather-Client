import 'package:client/api/location/location_repository.dart';
import 'package:client/model/location_temperature.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:client/service/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationRepositoryProvider = Provider((ref) => LocationRepository());
final locationServiceProvider = Provider((ref) => LocationService());

// 사용자 설정 위치 상태
final userLocationProvider = StateProvider<String?>((ref) => null);

final locationViewModelProvider =
    StateNotifierProvider<LocationViewModel, AsyncValue<LocationTemperature?>>(
        (ref) => LocationViewModel(ref));

class LocationViewModel
    extends StateNotifier<AsyncValue<LocationTemperature?>> {
  final Ref ref;

  LocationViewModel(this.ref) : super(const AsyncData(null));

  /// 위치 기반 온도 조회
  Future<void> fetchLocationTemperature({
    required int timeSlot,
    required String date,
  }) async {
    try {
      state = const AsyncLoading();

      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();

      final repo = ref.read(locationRepositoryProvider);
      final locationData = await repo.getLocationTemperature(
        latitude: position.latitude,
        longitude: position.longitude,
        timeSlot: timeSlot,
        date: date,
      );

      ref.read(addressProvider.notifier).state = locationData['regionName'];

      state = AsyncValue.data(LocationTemperature.fromJson(locationData));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 사용자 위치 조회
  Future<void> fetchUserLocation() async {
    try {
      state = const AsyncLoading();

      final repo = ref.read(locationRepositoryProvider);
      final userLocation = await repo.getUserLocation();

      // 사용자 위치를 상태에 저장
      ref.read(userLocationProvider.notifier).state = userLocation;

      state = const AsyncData(null);
    } catch (e, st) {
      print('사용자 위치 조회 오류: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// 사용자 위치 등록/수정
  Future<void> updateUserLocation(String regionName) async {
    try {
      final repo = ref.read(locationRepositoryProvider);
      final result = await repo.updateUserLocation(regionName);

      // 성공적으로 업데이트되면 로컬 상태도 업데이트
      ref.read(userLocationProvider.notifier).state = regionName;

      print('위치 업데이트 성공: $result');
    } catch (e) {
      print('사용자 위치 업데이트 오류: $e');
      // 에러를 다시 throw하여 UI에서 처리할 수 있도록 함
      rethrow;
    }
  }
}
