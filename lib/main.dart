import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/screens/signSplash.dart';
import 'package:client/screens/signUp/signUpEmail.dart';
import 'package:client/screens/signUp/signUpId.dart';
import 'package:client/screens/signUp/signUpNickname.dart';
import 'package:client/screens/signUp/signUpPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/signUp/nickname',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SignSplash(),
      ),
      GoRoute(
        path: '/signUp/email',
        builder: (context, state) => SignUpEmail(),
      ),
      GoRoute(
        path: '/signUp/id',
        builder: (context, state) => SignUpId(),
      ),
      GoRoute(
        path: '/signUp/password',
        builder: (context, state) => SignUpPassword(),
      ),
      GoRoute(
        path: '/signUp/nickname',
        builder: (context, state) => SignUpNickname(),
      ),
    ],
  );
});

void main() {
  runApp(const ProviderScope(child: HowWeather()));
}

class HowWeather extends ConsumerWidget {
  const HowWeather({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HowWeather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HowWeatherColor.white),
        appBarTheme: AppBarTheme(
            // systemOverlayStyle: SystemUiOverlayStyle(
            //   statusBarColor: Colors.transparent,
            //   statusBarIconBrightness: Brightness.light,
            // ),
            ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: HowWeatherColor.neutral[700],
          selectionColor: HowWeatherColor.neutral[700],
          selectionHandleColor: HowWeatherColor.neutral[700],
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
