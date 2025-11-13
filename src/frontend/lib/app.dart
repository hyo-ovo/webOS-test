import 'package:flutter/material.dart';
import 'features/weather_clock_display/presentation/info_section.dart';
import 'features/weather_clock_display/presentation/clock_widget.dart';
import 'features/weather_clock_display/presentation/weather_widget.dart';

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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}

/// 메인 홈 화면 - 디자인 명세서 기반 시계/날씨 위젯 표시
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 타이틀
                const Text(
                  'webOS Home Screen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 60),

                // 1. 통합 위젯 (메인 - 디자인 명세서 버전)
                const InfoSection(
                  cityName: 'Seoul',
                  showWeatherLoading: true,
                ),
                const SizedBox(height: 80),

                // 구분선
                Container(
                  width: 500,
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 60),

                // 라벨
                const Text(
                  '개별 위젯',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 40),

                // 2. 시간 위젯만
                const ClockWidget(),
                const SizedBox(height: 40),

                // 3. 날씨 위젯만
                const WeatherWidget(
                  cityName: 'Seoul',
                  showLoading: true,
                ),
                const SizedBox(height: 80),

                // 구분선
                Container(
                  width: 500,
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 60),

                // 라벨
                const Text(
                  '반응형 버전',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 40),

                // 4. 반응형 통합 위젯
                const ResponsiveInfoSection(
                  cityName: 'Seoul',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
