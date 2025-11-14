import '../data/weather_model.dart';
import '../data/repository_factory.dart';
import 'location_service.dart';

/// 날씨 비즈니스 로직 서비스
///
/// 역할: 날씨 관련 비즈니스 로직 처리
/// - Repository와 Controller 사이의 중간 계층
/// - 데이터 검증 및 변환
/// - 캐싱 로직 (선택적)
/// - 에러 처리 및 재시도 로직
/// - 환경에 따라 자동으로 적절한 Repository 사용
/// - 위치 서비스를 통한 자동 도시 감지
class WeatherService {
  final dynamic _repository;
  final LocationService _locationService;

  // 캐싱을 위한 변수
  WeatherModel? _cachedWeather;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  WeatherService({dynamic repository, LocationService? locationService})
      : _repository = repository ?? RepositoryFactory.createWeatherRepository(),
        _locationService = locationService ?? LocationService();

  /// 도시 이름으로 날씨 가져오기 (캐싱 포함)
  ///
  /// [cityName]: 도시 이름
  /// [forceRefresh]: true면 캐시 무시하고 새로 가져오기
  /// 반환: WeatherModel 객체
  Future<WeatherModel> getWeather(
    String cityName, {
    bool forceRefresh = false,
  }) async {
    // 유효한 캐시가 있으면 캐시 반환
    if (!forceRefresh && _isCacheValid()) {
      return _cachedWeather!;
    }

    try {
      // API에서 새 데이터 가져오기
      final weather = await _repository.getCurrentWeather(cityName);

      // 캐시 업데이트
      _cachedWeather = weather;
      _lastFetchTime = DateTime.now();

      return weather;
    } catch (e) {
      // 에러 발생 시 캐시된 데이터가 있으면 반환
      if (_cachedWeather != null) {
        return _cachedWeather!;
      }
      rethrow;
    }
  }

  /// 위도/경도로 날씨 가져오기
  ///
  /// [lat]: 위도
  /// [lon]: 경도
  /// [forceRefresh]: true면 캐시 무시하고 새로 가져오기
  Future<WeatherModel> getWeatherByCoordinates(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheValid()) {
      return _cachedWeather!;
    }

    try {
      final weather =
          await _repository.getCurrentWeatherByCoordinates(lat, lon);

      _cachedWeather = weather;
      _lastFetchTime = DateTime.now();

      return weather;
    } catch (e) {
      if (_cachedWeather != null) {
        return _cachedWeather!;
      }
      rethrow;
    }
  }

  /// 시스템 위치 기반 날씨 가져오기
  ///
  /// webOS: 시스템 설정의 도시 사용
  /// 로컬: 기본 도시 사용
  /// [forceRefresh]: true면 캐시 무시하고 새로 가져오기
  Future<WeatherModel> getWeatherBySystemLocation({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheValid()) {
      return _cachedWeather!;
    }

    try {
      // LocationService를 통해 시스템 도시 가져오기
      final cityName = await _locationService.getCurrentCity();

      // 해당 도시의 날씨 가져오기
      final weather = await _repository.getCurrentWeather(cityName);

      _cachedWeather = weather;
      _lastFetchTime = DateTime.now();

      return weather;
    } catch (e) {
      if (_cachedWeather != null) {
        return _cachedWeather!;
      }
      rethrow;
    }
  }

  /// 캐시가 유효한지 확인
  bool _isCacheValid() {
    if (_cachedWeather == null || _lastFetchTime == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastFetchTime!);

    return difference < _cacheValidDuration;
  }

  /// 캐시 초기화
  void clearCache() {
    _cachedWeather = null;
    _lastFetchTime = null;
  }

  /// 현재 캐시된 날씨 정보 반환 (없으면 null)
  WeatherModel? getCachedWeather() {
    return _isCacheValid() ? _cachedWeather : null;
  }

  /// 마지막 업데이트 시간 반환
  DateTime? getLastUpdateTime() {
    return _lastFetchTime;
  }

  /// 날씨 자동 새로고침 (주기적으로 호출)
  ///
  /// [cityName]: 도시 이름
  /// 반환: 성공 여부
  Future<bool> refreshWeather(String cityName) async {
    try {
      await getWeather(cityName, forceRefresh: true);
      return true;
    } catch (e) {
      return false;
    }
  }
}
