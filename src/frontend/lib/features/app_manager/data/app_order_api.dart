import 'dart:convert';
import 'package:http/http.dart' as http;

/// 백엔드 API와 통신하는 서비스
class AppOrderApi {
  // TODO: 환경에 맞게 baseUrl 설정
  static const String baseUrl = 'http://localhost:3000'; // 개발 환경

  /// 사용자별 앱 순서 조회
  ///
  /// Returns: 앱 ID 순서 배열
  static Future<List<String>> getUserAppOrder(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/apps/order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final appOrder = data['app_order'] as List?;
        return appOrder?.cast<String>() ?? [];
      } else {
        throw Exception('Failed to load app order: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 앱 순서 조회 실패: $e');
      return [];
    }
  }

  /// 사용자별 앱 순서 저장
  ///
  /// Parameters:
  /// - token: 사용자 인증 토큰
  /// - order: 앱 ID 순서 배열 (예: ['com.webos.app.browser', ...])
  static Future<bool> saveUserAppOrder(String token, List<String> order) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/apps/order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order': order,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 앱 순서 저장 성공');
        return true;
      } else {
        throw Exception('Failed to save app order: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 앱 순서 저장 실패: $e');
      return false;
    }
  }
}
