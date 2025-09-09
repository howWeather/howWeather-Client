import 'package:client/api/location/location_repository.dart';
import 'package:client/model/location_temperature.dart';
import 'package:client/providers/cloth_providers.dart';
import 'package:client/service/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationRepositoryProvider = Provider((ref) => LocationRepository());
final locationServiceProvider = Provider((ref) => LocationService());

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
}
