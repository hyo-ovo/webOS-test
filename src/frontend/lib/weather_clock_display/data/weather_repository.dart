import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

/// 날씨 데이터 저장소
///
/// 역할: 외부 날씨 API와 통신하여 데이터를 가져오는 책임
/// - API 호출 로직 캡슐화
/// - 에러 처리
/// - 데이터 변환 (JSON -> WeatherModel)
class WeatherRepository {
  // OpenWeatherMap API 설정
  static const String _apiKey = '84001a617861fd360e81ffa35df64b3e';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// 도시 이름으로 현재 날씨 가져오기
  ///
  /// [cityName]: 검색할 도시 이름 (예: "Seoul", "Busan")
  /// 반환: WeatherModel 객체
  /// 에러: API 호출 실패 시 Exception 발생
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=kr',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json);
      } else {
        throw Exception('날씨 정보를 가져오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('날씨 API 호출 중 오류 발생: $e');
    }
  }

  /// 위도/경도로 현재 날씨 가져오기
  ///
  /// [lat]: 위도
  /// [lon]: 경도
  /// 반환: WeatherModel 객체
  Future<WeatherModel> getCurrentWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=kr',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json);
      } else {
        throw Exception('날씨 정보를 가져오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('날씨 API 호출 중 오류 발생: $e');
    }
  }

  /// 5일 예보 가져오기 (향후 확장용)
  ///
  /// [cityName]: 검색할 도시 이름
  /// 반환: WeatherModel 리스트 (3시간 간격 예보)
  // Future<List<WeatherModel>> getForecast(String cityName) async {
  //   try {
  //     final url = Uri.parse(
  //       '$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric&lang=kr',
  //     );

  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final json = jsonDecode(response.body) as Map<String, dynamic>;
  //       final list = json['list'] as List<dynamic>;

  //       return list
  //           .map((item) => WeatherModel.fromJson(item as Map<String, dynamic>))
  //           .toList();
  //     } else {
  //       throw Exception('예보 정보를 가져오는데 실패했습니다. (${response.statusCode})');
  //     }
  //   } catch (e) {
  //     throw Exception('예보 API 호출 중 오류 발생: $e');
  //   }
  // }
}
