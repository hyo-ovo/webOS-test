import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webos_service_bridge/webos_service_bridge.dart';

// 직접 MethodChannel을 사용하는 대안 구현
class DirectLunaServiceBridge {
  static const MethodChannel _channel = MethodChannel('com.webos.service');
  
  static Future<Map<String, dynamic>?> callOneReply({
    required String uri,
    required String method,
    Map<String, dynamic>? payload = const <String, dynamic>{},
  }) async {
    try {
      debugPrint('[DirectLunaServiceBridge] 직접 MethodChannel 호출');
      debugPrint('[DirectLunaServiceBridge] URI: $uri');
      debugPrint('[DirectLunaServiceBridge] Method: $method');
      debugPrint('[DirectLunaServiceBridge] Payload: $payload');
      
      final fullPayload = <String, dynamic>{
        'method': method,
        if (payload != null) ...payload,
      };
      
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'call',
        {
          'uri': uri,
          'parameters': fullPayload,
        },
      );
      
      if (result != null) {
        final response = Map<String, dynamic>.from(
          result.map((key, value) => MapEntry(key.toString(), value)),
        );
        debugPrint('[DirectLunaServiceBridge] 응답: $response');
        return response;
      }
      
      debugPrint('[DirectLunaServiceBridge] 응답이 null입니다');
      return null;
    } on PlatformException catch (e) {
      debugPrint('[DirectLunaServiceBridge] PlatformException: ${e.code} - ${e.message}');
      return {
        'returnValue': false,
        'errorCode': -1,
        'errorText': 'PlatformException: ${e.message}',
      };
    } catch (e, stackTrace) {
      debugPrint('[DirectLunaServiceBridge] 에러: $e');
      debugPrint('[DirectLunaServiceBridge] 스택 트레이스: $stackTrace');
      return {
        'returnValue': false,
        'errorCode': -1,
        'errorText': 'Exception: $e',
      };
    }
  }
}

int generateHashCode(WebOSServiceData serviceData) =>
    '${serviceData.uri}${serviceData.payload}'.hashCode;

// Abstract base class for WebOSServiceBridge
abstract class WebOSServiceBridgeBase {
  Stream<Map<String, dynamic>> subscribe();
  Future<Map<String, dynamic>?> cancel();
}

// Wrapper for the actual WebOSServiceBridge from the plugin
class CustomWebOSServiceBridge implements WebOSServiceBridgeBase {
  // Factory constructor to return the single instance
  factory CustomWebOSServiceBridge(WebOSServiceData serviceData) {
    return CustomWebOSServiceBridge._internal(serviceData);
  }

  CustomWebOSServiceBridge._internal(WebOSServiceData serviceData)
      : _webOSServiceBridge = WebOSServiceBridge(
            serviceData.uri, serviceData.payload as Map<String, dynamic>);

  final WebOSServiceBridge _webOSServiceBridge;

  static Future<Map<String, dynamic>?> callOneReply(WebOSServiceData request) async {
    debugPrint('[CustomWebOSServiceBridge] callOneReply 시작');
    debugPrint('[CustomWebOSServiceBridge] URI: ${request.uri}');
    debugPrint('[CustomWebOSServiceBridge] Payload: ${request.payload}');
    
    try {
      // 원본 코드처럼 WebOSServiceBridge.callOneReply를 직접 호출
      debugPrint('[CustomWebOSServiceBridge] WebOSServiceBridge.callOneReply 직접 호출');
      final result = await WebOSServiceBridge.callOneReply(request);
      debugPrint('[CustomWebOSServiceBridge] callOneReply 응답: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('[CustomWebOSServiceBridge] callOneReply 에러: $e');
      debugPrint('[CustomWebOSServiceBridge] 스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>> subscribe() => _webOSServiceBridge.subscribe();

  @override
  Future<Map<String, dynamic>?> cancel() => _webOSServiceBridge.cancel();
}

class MockWebOSServiceBridge implements WebOSServiceBridgeBase {
  // Private constructor
  factory MockWebOSServiceBridge(WebOSServiceData serviceData) {
    return MockWebOSServiceBridge._internal(serviceData);
  }

  MockWebOSServiceBridge._internal(serviceData)
      : _serviceData = serviceData as WebOSServiceData;

  final WebOSServiceData _serviceData;

  static Future<Map<String, dynamic>> callOneReply(
      WebOSServiceData request) async {
    // Read the mock response from a local file
    // Mock 파일 경로: URI + method (payload에서 추출)
    final method = request.payload['method'] as String? ?? '';
    final String uriPath = request.uri.replaceFirst('luna://', '');
    final String mockPath = method.isNotEmpty ? '$uriPath/$method' : uriPath;
    String path = 'mocks/$mockPath-${generateHashCode(request)}.json';
    if (!kIsWeb) {
      path = 'assets/$path';
    }
    try {
      if (kIsWeb) {
        // For mobile platforms (Android/iOS)
        final String raw = await rootBundle.loadString(path);
        final Map<String, dynamic> response =
            jsonDecode(raw) as Map<String, dynamic>;
        return response;
      } else {
        // For Linux or other platforms
        if (File(path).existsSync()) {
          final String raw = File(path).readAsStringSync();
          final Map<String, dynamic> response =
              jsonDecode(raw) as Map<String, dynamic>;
          return response;
        } else {
          throw Exception('[linux]Mock response file not found : $path');
        }
      }
    } catch (e) {
      throw Exception('Mock response file not found : $path');
    }
  }

  @override
  Stream<Map<String, dynamic>> subscribe() async* {
    // Read the mock response from a local file
    // Mock 파일 경로: URI + method (payload에서 추출)
    final method = _serviceData.payload['method'] as String? ?? '';
    final String uriPath = _serviceData.uri.replaceFirst('luna://', '');
    final String mockPath = method.isNotEmpty ? '$uriPath/$method' : uriPath;
    String path = 'mocks/$mockPath-${generateHashCode(_serviceData)}.json';
    if (!kIsWeb) {
      path = 'assets/$path';
    }
    try {
      if (kIsWeb) {
        // For mobile platforms (Android/iOS)
        final String raw = await rootBundle.loadString(path);
        final Map<String, dynamic> response =
            jsonDecode(raw) as Map<String, dynamic>;
        yield response;
      } else {
        // For Linux or other platforms
        if (File(path).existsSync()) {
          final String raw = File(path).readAsStringSync();
          final Map<String, dynamic> response =
              jsonDecode(raw) as Map<String, dynamic>;
          yield response;
        } else {
          throw Exception('[linux]Mock response file not found : $path');
        }
      }
    } catch (e) {
      throw Exception('[all]Mock response file not found : $path');
    }
  }

  @override
  Future<Map<String, dynamic>?> cancel() async {
    // Mock cancel response
    return <String, dynamic>{
      'status': 'cancelled',
      'callId': _serviceData.hashCode
    };
  }
}
