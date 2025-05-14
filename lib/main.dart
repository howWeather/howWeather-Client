import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherNavi.dart';
import 'package:client/screens/calendar/view.dart';
import 'package:client/screens/mypage/clothes_enroll.dart';
import 'package:client/screens/mypage/mypage.dart';
import 'package:client/screens/mypage/profile.dart';
import 'package:client/screens/register/view.dart';
import 'package:client/screens/signSplash.dart';
import 'package:client/screens/signUp/signUpCheck.dart';
import 'package:client/screens/signUp/signUpEmail.dart';
import 'package:client/screens/signUp/signUpId.dart';
import 'package:client/screens/signUp/signUpNickname.dart';
import 'package:client/screens/signUp/signUpPassword.dart';
import 'package:client/screens/signUp/signUpPersonal.dart';
import 'package:client/screens/todayWear/view.dart';
import 'package:client/screens/todayWeather/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
      GoRoute(
        path: '/signUp/personal',
        builder: (context, state) => SignUpPersonal(),
      ),
      GoRoute(
        path: '/signUp/check',
        builder: (context, state) => SignUpCheck(),
      ),
      GoRoute(
        path: '/calendar/register',
        builder: (context, state) => Register(),
      ),
      GoRoute(
        path: '/mypage/profile',
        builder: (context, state) => Profile(),
      ),
      GoRoute(
        path: '/mypage/clothes/enroll',
        builder: (context, state) => ClothesEnroll(),
      ),
      ShellRoute(
        builder: (context, state, child) => HowWeatherNaviShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => WeatherScreen(),
          ),
          GoRoute(
            path: '/todaywear',
            builder: (context, state) => TodayWear(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => Calendar(),
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => MyPage(),
          ),
        ],
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await dotenv.load(fileName: ".env");
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
