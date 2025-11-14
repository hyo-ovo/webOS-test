import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// webOS Luna Service 호출 유틸리티
/// 
/// webOS의 Luna Service API를 Flutter에서 호출하기 위한 유틸리티 클래스입니다.
/// MethodChannel을 통해 네이티브 코드와 통신합니다.
class WebOSLunaService {
  static const MethodChannel _channel = MethodChannel('com.webos.luna_service');

  /// Luna Service를 호출하고 응답을 반환합니다.
  /// 
  /// [uri] Luna Service URI (예: 'luna://com.palm.db')
  /// [method] 호출할 메서드 이름
  /// [parameters] 메서드에 전달할 파라미터
  /// 
  /// Returns: 응답 데이터 (Map<String, dynamic>)
  /// Throws: Exception if the call fails
  static Future<Map<String, dynamic>?> callOneReply({
    required String uri,
    required String method,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // 웹 환경에서는 Luna Service를 사용할 수 없으므로 null 반환
      if (kIsWeb) {
        if (kDebugMode) {
          print('Web environment: Luna Service not available');
        }
        return null;
      }

      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'callLunaService',
        {
          'uri': uri,
          'method': method,
          'parameters': parameters ?? {},
        },
      );

      if (result == null) {
        return null;
      }

      // Map<Object?, Object?>를 Map<String, dynamic>으로 변환
      return result.map((key, value) => MapEntry(
            key.toString(),
            value is Map ? Map<String, dynamic>.from(value as Map) : value,
          )) as Map<String, dynamic>?;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Luna Service call failed: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in Luna Service call: $e');
      }
      return null;
    }
  }
}

