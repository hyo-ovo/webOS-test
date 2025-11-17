import 'package:flutter/material.dart';
import 'features/app_manager/presentation/widgets/app_launcher_widget.dart';
import 'features/user_login/presentation/initial_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'webOS Home Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        useMaterial3: true,
        fontFamily: 'Pretendard', // Pretendard 기본 폰트 설정
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: 'Pretendard'),
          bodyMedium: TextStyle(fontFamily: 'Pretendard'),
          labelLarge: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500),
        ),
      ),
      home: const InitialScreen(),
    );
  }
}
