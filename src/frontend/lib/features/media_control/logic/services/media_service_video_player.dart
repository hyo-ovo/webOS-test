import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import 'media_service_interface.dart';

/// video_player 패키지를 사용하는 MediaService 구현
/// 
/// 주의: 이 구현은 Flutter 앱 내에서만 비디오를 재생합니다.
/// TV 전체 화면 재생이 필요한 경우 Luna API를 사용해야 합니다.
MediaService getMediaService() {
  debugPrint('[MediaService] video_player 패키지 사용 (대안 구현)');
  return _VideoPlayerMediaService();
}

class _VideoPlayerMediaService extends MediaService {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, String> _sessionIdToUri = {};

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
    try {
      debugPrint('[VideoPlayer] open() 호출: $uri');
      
      // sessionId 생성 (간단한 해시 사용)
      final sessionId = 'video_player_${uri.hashCode}';
      
      // VideoPlayerController 생성
      final controller = VideoPlayerController.networkUrl(Uri.parse(uri));
      
      debugPrint('[VideoPlayer] VideoPlayerController 생성 중...');
      await controller.initialize();
      
      debugPrint('[VideoPlayer] ✅ 초기화 완료');
      
      // 컨트롤러 저장
      _controllers[sessionId] = controller;
      _sessionIdToUri[sessionId] = uri;
      
      // 볼륨 설정 (options에서 가져오거나 기본값 50)
      final volume = (options?['volume'] as num?)?.toDouble() ?? 50.0;
      await controller.setVolume(volume / 100.0);
      
      debugPrint('[VideoPlayer] ✅ open 성공 - sessionId: $sessionId');
      return sessionId;
    } catch (e, stackTrace) {
      debugPrint('[VideoPlayer] ❌ open 에러: $e');
      debugPrint('[VideoPlayer] 스택 트레이스: $stackTrace');
      return null;
    }
  }

  @override
  Future<void> play(String sessionId) async {
    try {
      debugPrint('[VideoPlayer] play() 호출: $sessionId');
      final controller = _controllers[sessionId];
      if (controller != null) {
        await controller.play();
        debugPrint('[VideoPlayer] ✅ play 성공');
      } else {
        debugPrint('[VideoPlayer] ❌ play 실패 - controller를 찾을 수 없음: $sessionId');
      }
    } catch (e) {
      debugPrint('[VideoPlayer] ❌ play 에러: $e');
    }
  }

  @override
  Future<void> pause(String sessionId) async {
    try {
      debugPrint('[VideoPlayer] pause() 호출: $sessionId');
      final controller = _controllers[sessionId];
      if (controller != null) {
        await controller.pause();
        debugPrint('[VideoPlayer] ✅ pause 성공');
      } else {
        debugPrint('[VideoPlayer] ❌ pause 실패 - controller를 찾을 수 없음: $sessionId');
      }
    } catch (e) {
      debugPrint('[VideoPlayer] ❌ pause 에러: $e');
    }
  }

  @override
  Future<void> stop(String sessionId) async {
    try {
      debugPrint('[VideoPlayer] stop() 호출: $sessionId');
      final controller = _controllers[sessionId];
      if (controller != null) {
        await controller.pause();
        await controller.seekTo(Duration.zero);
        debugPrint('[VideoPlayer] ✅ stop 성공');
      } else {
        debugPrint('[VideoPlayer] ❌ stop 실패 - controller를 찾을 수 없음: $sessionId');
      }
    } catch (e) {
      debugPrint('[VideoPlayer] ❌ stop 에러: $e');
    }
  }

  @override
  Future<void> close(String sessionId) async {
    try {
      debugPrint('[VideoPlayer] close() 호출: $sessionId');
      final controller = _controllers[sessionId];
      if (controller != null) {
        await controller.dispose();
        _controllers.remove(sessionId);
        _sessionIdToUri.remove(sessionId);
        debugPrint('[VideoPlayer] ✅ close 성공');
      } else {
        debugPrint('[VideoPlayer] ❌ close 실패 - controller를 찾을 수 없음: $sessionId');
      }
    } catch (e) {
      debugPrint('[VideoPlayer] ❌ close 에러: $e');
    }
  }

  /// VideoPlayerController 가져오기 (위젯에서 사용)
  VideoPlayerController? getController(String sessionId) {
    return _controllers[sessionId];
  }

  /// 모든 컨트롤러 정리
  Future<void> disposeAll() async {
    debugPrint('[VideoPlayer] 모든 컨트롤러 정리 중...');
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
    _sessionIdToUri.clear();
    debugPrint('[VideoPlayer] ✅ 모든 컨트롤러 정리 완료');
  }
}

