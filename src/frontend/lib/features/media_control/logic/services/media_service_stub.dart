import 'package:flutter/foundation.dart';

import 'media_service_interface.dart';
import 'media_service_webos.dart' as webos_service;

/// MediaService - webOS Luna Service 사용
///
/// luna://com.webos.media API를 통한 미디어 재생
MediaService getMediaService() {
  debugPrint('[MediaService] webOS Luna Service 사용');
  return webos_service.getMediaService();
}
