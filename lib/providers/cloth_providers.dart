import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/model/cloth_item.dart';

// 1. 카테고리별 선택된 아이템 ID 관리
final selectedClothProvider =
    StateProvider.family<int?, String>((ref, category) => null);

// 2. 카테고리별 선택된 아이템 정보 관리 (ClothItem 객체)
final selectedClothInfoProvider =
    StateProvider.family<ClothItem?, String>((ref, category) => null);

// 3. 등록 페이지용 카테고리별 선택된 의류 ID 맵
final selectedEnrollClothProvider = StateProvider<Map<String, int?>>((ref) => {
      'uppers': null,
      'outers': null,
    });

// 4. 등록 페이지용 최종 선택된 아이템들
final registerUpperProvider = StateProvider<ClothItem?>((ref) => null);
final registerOuterProvider = StateProvider<ClothItem?>((ref) => null);

// 5. 기타 설정값들
final colorProvider = StateProvider<int>((ref) => 1);
final thicknessProvider = StateProvider<int>((ref) => 1);
final selectedTemperatureProvider = StateProvider<int?>((ref) => null);
final addressProvider = StateProvider<String>((ref) => "");

// 6. 모든 provider 초기화 헬퍼
extension ProviderHelper on WidgetRef {
  void resetClothProviders() {
    read(selectedClothProvider("uppers").notifier).state = null;
    read(selectedClothProvider("outers").notifier).state = null;
    read(selectedClothInfoProvider("uppers").notifier).state = null;
    read(selectedClothInfoProvider("outers").notifier).state = null;
    read(selectedEnrollClothProvider.notifier).state = {
      'uppers': null,
      'outers': null,
    };
    read(registerUpperProvider.notifier).state = null;
    read(registerOuterProvider.notifier).state = null;
    read(colorProvider.notifier).state = 1;
    read(thicknessProvider.notifier).state = 1;
    read(selectedTemperatureProvider.notifier).state = null;
    read(addressProvider.notifier).state = "";
  }
}

extension ProviderHelper2 on WidgetRef {
  void resetClothInfoProviders() {
    read(selectedClothInfoProvider("uppers").notifier).state = null;
    read(selectedClothInfoProvider("outers").notifier).state = null;
    read(selectedEnrollClothProvider.notifier).state = {
      'uppers': null,
      'outers': null,
    };
    read(registerUpperProvider.notifier).state = null;
    read(registerOuterProvider.notifier).state = null;
    read(colorProvider.notifier).state = 1;
    read(thicknessProvider.notifier).state = 1;
  }
}
