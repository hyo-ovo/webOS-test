import 'package:flutter/foundation.dart';
import 'package:frontend/features/media_control/logic/services/volume_service.dart';
import 'package:frontend/features/media_control/logic/services/volume_service_interface.dart';

/// 시스템 볼륨 컨트롤러
///
/// 시스템 볼륨 상태 관리 및 제어를 담당
class VolumeController extends ChangeNotifier {
  VolumeController() {
    _initialize();
  }

  final VolumeService _volumeService = volumeService;

  // === State ===

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // === Initialization ===

  /// 초기화 (현재 볼륨 상태 확인)
  Future<void> _initialize() async {
    // TODO: 현재 볼륨 상태를 가져오는 API가 있다면 여기서 호출
    // 현재는 Luna API에 볼륨 조회 기능이 없으므로 기본값 사용
  }

  // === Volume Control ===

  /// 볼륨 증가
  Future<void> volumeUp() async {
    if (_isLoading) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _volumeService.volumeUp();
      if (success) {
        // 볼륨 증가 시 음소거 해제
        if (_isMuted) {
          _isMuted = false;
        }
        debugPrint('[VolumeController] 볼륨 증가 성공');
      } else {
        _setError('볼륨 증가 실패');
      }
    } catch (e) {
      _setError('볼륨 증가 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 볼륨 감소
  Future<void> volumeDown() async {
    if (_isLoading) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _volumeService.volumeDown();
      if (success) {
        debugPrint('[VolumeController] 볼륨 감소 성공');
      } else {
        _setError('볼륨 감소 실패');
      }
    } catch (e) {
      _setError('볼륨 감소 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 음소거 토글
  Future<void> toggleMute() async {
    if (_isLoading) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final newMutedState = !_isMuted;
      final success = await _volumeService.setMuted(newMutedState);

      if (success) {
        _isMuted = newMutedState;
        debugPrint('[VolumeController] 음소거 ${newMutedState ? "켜짐" : "꺼짐"}');
      } else {
        _setError('음소거 설정 실패');
      }
    } catch (e) {
      _setError('음소거 설정 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 음소거 설정
  Future<void> setMuted(bool muted) async {
    if (_isLoading || _isMuted == muted) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _volumeService.setMuted(muted);

      if (success) {
        _isMuted = muted;
        debugPrint('[VolumeController] 음소거 ${muted ? "켜짐" : "꺼짐"}');
      } else {
        _setError('음소거 설정 실패');
      }
    } catch (e) {
      _setError('음소거 설정 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  // === Private Methods ===

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint('[VolumeController] Error: $message');
    notifyListeners();
  }
}

