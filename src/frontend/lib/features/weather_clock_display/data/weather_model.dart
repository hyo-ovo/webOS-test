/// 날씨 데이터 모델
///
/// 날씨 API로부터 받은 데이터를 앱에서 사용 가능한 형태로 변환
class WeatherModel {
  final String cityName;
  final double temperature; // 섭씨 온도
  final String condition; // 날씨 상태 (예: "맑음", "흐림", "비")
  final String iconCode; // 날씨 아이콘 코드
  final double humidity; // 습도 (%)
  final double windSpeed; // 풍속 (m/s)
  final DateTime lastUpdated; // 마지막 업데이트 시간

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
  });

  /// API 응답 JSON을 WeatherModel로 변환
  ///
  /// OpenWeatherMap API 응답 예시:
  /// ```json
  /// {
  ///   "name": "Seoul",
  ///   "main": {"temp": 15.5, "humidity": 60},
  ///   "weather": [{"main": "Clear", "icon": "01d"}],
  ///   "wind": {"speed": 3.5}
  /// }
  /// ```
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']?['temp'] ?? 0.0).toDouble(),
      condition: _translateCondition(json['weather']?[0]?['main'] ?? 'Unknown'),
      iconCode: json['weather']?[0]?['icon'] ?? '01d',
      humidity: (json['main']?['humidity'] ?? 0.0).toDouble(),
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.now(),
    );
  }

  /// 영어 날씨 상태를 한글로 변환
  static String _translateCondition(String condition) {
    const Map<String, String> conditionMap = {
      'Clear': '맑음',
      'Clouds': '흐림',
      'Rain': '비',
      'Drizzle': '이슬비',
      'Thunderstorm': '천둥번개',
      'Snow': '눈',
      'Mist': '안개',
      'Smoke': '연무',
      'Haze': '실안개',
      'Dust': '먼지',
      'Fog': '안개',
      'Sand': '황사',
      'Ash': '화산재',
      'Squall': '돌풍',
      'Tornado': '토네이도',
    };
    return conditionMap[condition] ?? condition;
  }

  /// WeatherModel을 JSON으로 변환 (캐싱 등에 사용)
  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {
        'temp': temperature,
        'humidity': humidity,
      },
      'weather': [
        {
          'main': condition,
          'icon': iconCode,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// 날씨 아이콘 이미지 URL 반환
  String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  String toString() {
    return 'WeatherModel(city: $cityName, temp: $temperature°C, condition: $condition)';
  }
}
