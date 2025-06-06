import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/api/model/model_repository.dart';
import 'package:client/model/model_recommendation.dart';

final modelViewModelProvider =
    StateNotifierProvider<ModelNotifier, AsyncValue<List<ModelRecommendation>>>(
  (ref) => ModelNotifier(ref),
);

class ModelNotifier
    extends StateNotifier<AsyncValue<List<ModelRecommendation>>> {
  final Ref ref;

  ModelNotifier(this.ref) : super(const AsyncLoading());

  Future<void> fetchRecommendation() async {
    try {
      final repo = ModelRepository();
      final result = await repo.fetchModelRecommendation();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
