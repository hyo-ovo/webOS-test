import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/webos_service_helper/utils.dart' as webos_utils;

import 'media_service_interface.dart';
import 'media_service_video_player.dart' as video_player_service;

/// MediaService 선택
/// 
/// Luna API가 작동하지 않는 경우 video_player 패키지를 사용하는 대안 제공
/// 환경 변수 USE_VIDEO_PLAYER=true로 설정하면 video_player 사용
MediaService getMediaService() {
  // 환경 변수로 강제 선택 가능
  const useVideoPlayer = bool.fromEnvironment('USE_VIDEO_PLAYER', defaultValue: false);
  
  if (useVideoPlayer) {
    debugPrint('[MediaService] video_player 패키지 사용 (환경 변수 설정)');
    return video_player_service.getMediaService();
  } else {
    debugPrint('[MediaService] WebOSServiceBridge 사용 (Luna API)');
    return const _NativeWebOSMediaService();
  }
}

class _NativeWebOSMediaService extends MediaService {
  const _NativeWebOSMediaService();
  
  // video_player 폴백 서비스
  static final _videoPlayerService = video_player_service.getMediaService();
  static bool _useVideoPlayerFallback = false;

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
    // 이미 video_player로 폴백한 경우
    if (_useVideoPlayerFallback) {
      debugPrint('[MediaService] video_player 폴백 사용 중');
      return _videoPlayerService.open(uri, options: options);
    }
    
    try {
      final parameters = <String, dynamic>{
        'uri': uri,
        'type': 'media',
        'mediaFormat': 'video',
        'option': {
          'mediaTransportType': uri.startsWith('http') ? 'STREAMING' : 'FILE',
        },
      };
      if (options != null) {
        parameters.addAll(options);
      }

      debugPrint('[Luna API] 호출: luna://com.webos.media/open');
      debugPrint('[Luna API] 파라미터: $parameters');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: 'open',
        payload: parameters,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('[Luna API] ⚠️ 타임아웃 (5초) - video_player로 폴백');
          return <String, dynamic>{
            'returnValue': false,
            'errorCode': -1,
            'errorText': 'Timeout - falling back to video_player',
          };
        },
      );

      debugPrint('[Luna API] 응답: $result');

      if (result != null && result['returnValue'] == true) {
        final sessionId = result['sessionId'] as String?;
        debugPrint('[Luna API] ✅ 성공 - sessionId: $sessionId');
        return sessionId;
      }

      // 에러 정보 상세 로깅
      final errorCode = result?['errorCode'];
      final errorText = result?['errorText'];
      debugPrint('[Luna API] ❌ 실패 - returnValue: ${result?['returnValue']}');
      debugPrint('[Luna API] ❌ errorCode: $errorCode');
      debugPrint('[Luna API] ❌ errorText: $errorText');
      debugPrint('[Luna API] ❌ 전체 응답: $result');
      
      // Luna API 실패 시 video_player로 폴백
      debugPrint('[MediaService] ⚠️ Luna API 실패 - video_player로 폴백 시도');
      _useVideoPlayerFallback = true;
      return _videoPlayerService.open(uri, options: options);
    } catch (e) {
      debugPrint('[Luna API] ❌ 에러: $e');
      debugPrint('[MediaService] ⚠️ Luna API 예외 - video_player로 폴백 시도');
      _useVideoPlayerFallback = true;
      return _videoPlayerService.open(uri, options: options);
    }
  }

  @override
  Future<void> play(String sessionId) {
    if (_useVideoPlayerFallback) {
      return _videoPlayerService.play(sessionId);
    }
    return _invokeSimple('play', sessionId);
  }

  @override
  Future<void> pause(String sessionId) {
    if (_useVideoPlayerFallback) {
      return _videoPlayerService.pause(sessionId);
    }
    return _invokeSimple('pause', sessionId);
  }

  @override
  Future<void> stop(String sessionId) {
    if (_useVideoPlayerFallback) {
      return _videoPlayerService.stop(sessionId);
    }
    return _invokeSimple('stop', sessionId);
  }

  @override
  Future<void> close(String sessionId) {
    if (_useVideoPlayerFallback) {
      return _videoPlayerService.close(sessionId);
    }
    return _invokeSimple('close', sessionId);
  }

  Future<void> _invokeSimple(String method, String sessionId) async {
    try {
      debugPrint('[Luna API] 호출: luna://com.webos.media/$method');
      debugPrint('[Luna API] sessionId: $sessionId');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: method,
        payload: {'sessionId': sessionId},
      );

      debugPrint('[Luna API] $method 응답: $result');

      if (result != null && result['returnValue'] == true) {
        debugPrint('[Luna API] ✅ $method 성공');
      } else {
        // 에러 정보 상세 로깅
        final errorCode = result?['errorCode'];
        final errorText = result?['errorText'];
        debugPrint('[Luna API] ❌ $method 실패 - returnValue: ${result?['returnValue']}');
        debugPrint('[Luna API] ❌ $method errorCode: $errorCode');
        debugPrint('[Luna API] ❌ $method errorText: $errorText');
        debugPrint('[Luna API] ❌ $method 전체 응답: $result');
      }
    } catch (e) {
      debugPrint('[Luna API] ❌ $method 에러: $e');
      debugPrint('[Luna API] ❌ $method 에러 스택: ${StackTrace.current}');
    }
  }
}
