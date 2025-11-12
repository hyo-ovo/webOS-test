import 'package:flutter/material.dart';
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
      ),
      home: const InitialScreen(), // 로그인/회원가입 플로우 시작
    );
  }
}
