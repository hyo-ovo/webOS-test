import 'package:flutter/material.dart';
import 'app.dart';
import 'features/weather_clock_display/data/repository_factory.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 정보 출력 (webOS인지 로컬인지 확인)
  EnvironmentConfig.printEnvironmentInfo();

  // webOS 환경 테스트를 위해 강제로 webOS 모드 활성화하려면 아래 주석 해제
  // EnvironmentConfig.forceWebOS(true);

  // 로컬 환경 테스트를 위해 강제로 로컬 모드 활성화하려면 아래 주석 해제
  // EnvironmentConfig.forceLocal(true);

  runApp(const MyApp());
}
