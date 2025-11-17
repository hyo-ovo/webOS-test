import 'package:frontend/features/media_control/data/models/media_item.dart';
import 'package:frontend/features/media_control/logic/services/media_service_interface.dart';
import 'package:frontend/features/media_control/logic/services/volume_service_interface.dart';

/// 미디어 Repository
///
/// MediaService와 VolumeService를 래핑하여
/// 비즈니스 로직 계층에서 사용할 수 있는 인터페이스 제공
class MediaRepository {
  MediaRepository({
    required MediaService mediaService,
    required VolumeService volumeService,
  })  : _mediaService = mediaService,
        _volumeService = volumeService;

  final MediaService _mediaService;
  final VolumeService _volumeService;

  // === Media Control ===

  /// 미디어 열기
  Future<String?> openMedia(MediaItem item) async {
    return await _mediaService.open(item.url);
  }

  /// 미디어 재생
  Future<void> playMedia(String sessionId) async {
    await _mediaService.play(sessionId);
  }

  /// 미디어 일시정지
  Future<void> pauseMedia(String sessionId) async {
    await _mediaService.pause(sessionId);
  }

  /// 미디어 정지
  Future<void> stopMedia(String sessionId) async {
    await _mediaService.stop(sessionId);
  }

  /// 미디어 닫기
  Future<void> closeMedia(String sessionId) async {
    await _mediaService.close(sessionId);
  }

  // === Volume Control ===

  /// 볼륨 증가
  Future<bool> volumeUp() async {
    return await _volumeService.volumeUp();
  }

  /// 볼륨 감소
  Future<bool> volumeDown() async {
    return await _volumeService.volumeDown();
  }

  /// 음소거 설정
  Future<bool> setMuted(bool muted) async {
    return await _volumeService.setMuted(muted);
  }
}
