import 'package:flutter/material.dart';
import 'features/weather_clock_display/presentation/info_section.dart';
import 'features/weather_clock_display/presentation/clock_widget.dart';
import 'features/weather_clock_display/presentation/weather_widget.dart';
import 'features/app_manager/presentation/widgets/app_launcher_widget.dart';
import 'features/user_login/presentation/initial_screen.dart';
import 'home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'webOS Home Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        fontFamily: 'Pretendard', // Pretendard 기본 폰트 설정
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: 'Pretendard'),
          bodyMedium: TextStyle(fontFamily: 'Pretendard'),
          labelLarge:
              TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500),
        ),
      ),
      //home: const HomeScreen(),
      home: const InitialScreen(),
    );
  }
}
