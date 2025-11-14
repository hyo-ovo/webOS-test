import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/weather_model.dart';
import 'weather_service.dart';

/// 날씨 상태 관리 컨트롤러
///
/// 역할: UI와 비즈니스 로직을 연결하는 상태 관리
/// - ChangeNotifier를 사용한 상태 관리
/// - UI에 필요한 데이터 제공
/// - 로딩/에러 상태 관리
/// - 자동 새로고침 타이머 관리
class WeatherController extends ChangeNotifier {
  final WeatherService _service;

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  // 기본 도시 설정 (서울)
  String _currentCity = 'Seoul';

  WeatherController({WeatherService? service})
      : _service = service ?? WeatherService();

  // Getters
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;

  /// 날씨 정보 로드
  ///
  /// [cityName]: 검색할 도시 이름 (선택적)
  /// - cityName이 있으면: 해당 도시 날씨 가져오기
  /// - cityName이 없으면: 시스템 위치 기반 날씨 가져오기 (webOS: 시스템 도시, 로컬: 서울)
  Future<void> loadWeather({String? cityName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (cityName != null && cityName.isNotEmpty) {
        // 특정 도시 지정
        _weather = await _service.getWeather(cityName);
        _currentCity = cityName;
      } else {
        // 시스템 위치 기반 (webOS: 시스템 도시, 로컬: 서울)
        _weather = await _service.getWeatherBySystemLocation();
        _currentCity = _weather?.cityName ?? _currentCity;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '날씨 정보를 불러올 수 없습니다: $e';
      // 에러 발생 시 캐시된 데이터라도 표시
      _weather = _service.getCachedWeather();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 위도/경도로 날씨 정보 로드
  Future<void> loadWeatherByCoordinates(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _service.getWeatherByCoordinates(lat, lon);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '날씨 정보를 불러올 수 없습니다: $e';
      _weather = _service.getCachedWeather();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 날씨 정보 새로고침
  Future<void> refreshWeather() async {
    await loadWeather(cityName: _currentCity);
  }

  /// 자동 새로고침 시작
  ///
  /// [interval]: 새로고침 간격 (기본: 10분)
  void startAutoRefresh({Duration interval = const Duration(minutes: 10)}) {
    stopAutoRefresh(); // 기존 타이머 정리

    _refreshTimer = Timer.periodic(interval, (_) {
      refreshWeather();
    });
  }

  /// 자동 새로고침 중지
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 도시 변경
  Future<void> changeCity(String cityName) async {
    await loadWeather(cityName: cityName);
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}

/// 시계 컨트롤러
///
/// 역할: 실시간 시간 표시를 위한 상태 관리
/// - 1초마다 현재 시간 업데이트
/// - 날짜/시간 포맷팅
class ClockController extends ChangeNotifier {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  DateTime get currentTime => _currentTime;

  /// 시계 시작
  void start() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  /// 시계 중지
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateTime() {
    _currentTime = DateTime.now();
    notifyListeners();
  }

  /// 시간 포맷 (예: "14:30:45")
  String getFormattedTime() {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:'
        '${_currentTime.minute.toString().padLeft(2, '0')}:'
        '${_currentTime.second.toString().padLeft(2, '0')}';
  }

  // /// 날짜 포맷 (예: "2025년 11월 13일 수요일")
  // String getFormattedDate() {
  //   const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  //   final weekday = weekdays[_currentTime.weekday - 1];

  //   return '${_currentTime.year}년 '
  //       '${_currentTime.month}월 '
  //       '${_currentTime.day}일 '
  //       '$weekday요일';
  // }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
