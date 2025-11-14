import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webos_service_bridge/webos_service_bridge.dart';

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
      // WebOSServiceBridge 인스턴스를 생성하여 호출 시도
      // 플러그인이 static callOneReply 대신 인스턴스 메서드를 사용할 수 있음
      final bridge = WebOSServiceBridge(
        request.uri,
        request.payload as Map<String, dynamic>,
      );
      
      debugPrint('[CustomWebOSServiceBridge] WebOSServiceBridge 인스턴스 생성 완료');
      
      // subscribe를 통해 응답을 받는 방식으로 시도
      final completer = Completer<Map<String, dynamic>?>();
      final subscription = bridge.subscribe().listen(
        (response) {
          debugPrint('[CustomWebOSServiceBridge] subscribe 응답: $response');
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        },
        onError: (error) {
          debugPrint('[CustomWebOSServiceBridge] subscribe 에러: $error');
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        onDone: () {
          debugPrint('[CustomWebOSServiceBridge] subscribe 완료');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        cancelOnError: false,
      );
      
      // 타임아웃 추가 (30초)
      final result = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('[CustomWebOSServiceBridge] callOneReply 타임아웃 (30초)');
          subscription.cancel();
          return <String, dynamic>{
            'returnValue': false,
            'errorCode': -1,
            'errorText': 'Request timeout after 30 seconds',
          };
        },
      );
      
      await subscription.cancel();
      debugPrint('[CustomWebOSServiceBridge] callOneReply 완료: $result');
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
