import 'package:client/api/cloth/cloth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clothViewModelProvider =
    StateNotifierProvider<ClothNotifier, AsyncValue<String>>(
  (ref) => ClothNotifier(ref),
);

class ClothNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref ref;

  ClothNotifier(this.ref) : super(const AsyncData(''));

  Future<String> getUpperClothImage(int clothType) async {
    try {
      final repo = ClothRepository();
      final clothes = await repo.getUpperClothImage(clothType);
      state = AsyncValue.data(clothes);
      return clothes;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return '';
    }
  }
}
