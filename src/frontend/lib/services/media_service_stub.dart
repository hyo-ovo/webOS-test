import 'package:flutter/foundation.dart';

import 'media_service_interface.dart';
import 'media_service_video_player.dart' as video_player_service;

/// MediaService - video_player 패키지 사용
/// 
/// Luna API 대신 video_player를 직접 사용하여 비디오 재생
MediaService getMediaService() {
  debugPrint('[MediaService] video_player 패키지 사용');
  return video_player_service.getMediaService();
}
