import 'package:client/api/oauth2/oauth2_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final oauth2RepositoryProvider = Provider((ref) => Oauth2Repository());

final oauth2ViewModelProvider =
    StateNotifierProvider<Oauth2ViewModel, AsyncValue<void>>(
  (ref) => Oauth2ViewModel(ref),
);

class Oauth2ViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  Oauth2ViewModel(this.ref) : super(const AsyncData(null));

  // 소셜로그인-카카오
  Future<void> loginKakao() async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(oauth2RepositoryProvider);
      final tokens = await repo.socialLoginKaKao();

      print('AccessToken: ${tokens['accessToken']}');
      print('RefreshToken: ${tokens['refreshToken']}');

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
