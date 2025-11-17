import 'package:flutter/foundation.dart';
import 'package:frontend/features/media_control/data/models/media_item.dart';
import 'package:frontend/features/media_control/data/repositories/media_repository.dart';

/// 미디어 컨트롤러
///
/// 미디어 재생 상태 관리 및 제어를 담당
class MediaController extends ChangeNotifier {
  MediaController({
    required MediaRepository repository,
  }) : _repository = repository;

  final MediaRepository _repository;

  // === State ===

  MediaItem? _currentMedia;
  MediaItem? get currentMedia => _currentMedia;

  String? _sessionId;
  String? get sessionId => _sessionId;

  MediaPlaybackState _playbackState = MediaPlaybackState.idle;
  MediaPlaybackState get playbackState => _playbackState;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // === Media Control ===

  /// 미디어 열기 및 재생
  Future<void> openAndPlay(MediaItem item) async {
    try {
      _setPlaybackState(MediaPlaybackState.loading);
      _currentMedia = item;
      _errorMessage = null;

      final sessionId = await _repository.openMedia(item);

      if (sessionId != null) {
        _sessionId = sessionId;
        await _repository.playMedia(sessionId);
        _setPlaybackState(MediaPlaybackState.playing);
      } else {
        _setError('미디어를 열 수 없습니다');
      }
    } catch (e) {
      _setError('미디어 재생 오류: $e');
    }
  }

  /// 재생
  Future<void> play() async {
    if (_sessionId == null) {
      debugPrint('[MediaController] sessionId is null, cannot play');
      return;
    }

    try {
      await _repository.playMedia(_sessionId!);
      _setPlaybackState(MediaPlaybackState.playing);
    } catch (e) {
      _setError('재생 오류: $e');
    }
  }

  /// 일시정지
  Future<void> pause() async {
    if (_sessionId == null) {
      debugPrint('[MediaController] sessionId is null, cannot pause');
      return;
    }

    try {
      await _repository.pauseMedia(_sessionId!);
      _setPlaybackState(MediaPlaybackState.paused);
    } catch (e) {
      _setError('일시정지 오류: $e');
    }
  }

  /// 정지
  Future<void> stop() async {
    if (_sessionId == null) {
      debugPrint('[MediaController] sessionId is null, cannot stop');
      return;
    }

    try {
      await _repository.stopMedia(_sessionId!);
      _setPlaybackState(MediaPlaybackState.stopped);
    } catch (e) {
      _setError('정지 오류: $e');
    }
  }

  /// 닫기
  Future<void> close() async {
    if (_sessionId == null) {
      debugPrint('[MediaController] sessionId is null, cannot close');
      return;
    }

    try {
      await _repository.closeMedia(_sessionId!);
      _sessionId = null;
      _currentMedia = null;
      _setPlaybackState(MediaPlaybackState.idle);
    } catch (e) {
      _setError('닫기 오류: $e');
    }
  }

  // === Volume Control ===

  /// 볼륨 증가
  Future<void> volumeUp() async {
    try {
      await _repository.volumeUp();
    } catch (e) {
      debugPrint('[MediaController] 볼륨 증가 오류: $e');
    }
  }

  /// 볼륨 감소
  Future<void> volumeDown() async {
    try {
      await _repository.volumeDown();
    } catch (e) {
      debugPrint('[MediaController] 볼륨 감소 오류: $e');
    }
  }

  /// 음소거 토글
  Future<void> toggleMute() async {
    try {
      final newMutedState = !_isMuted;
      final success = await _repository.setMuted(newMutedState);

      if (success) {
        _isMuted = newMutedState;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[MediaController] 음소거 토글 오류: $e');
    }
  }

  // === Private Methods ===

  void _setPlaybackState(MediaPlaybackState state) {
    _playbackState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _playbackState = MediaPlaybackState.error;
    debugPrint('[MediaController] Error: $message');
    notifyListeners();
  }

  @override
  void dispose() {
    // 컨트롤러 dispose 시 미디어 세션 정리
    if (_sessionId != null) {
      close();
    }
    super.dispose();
  }
}
