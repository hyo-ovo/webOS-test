import 'package:flutter/foundation.dart';

import 'volume_service_interface.dart';
import 'volume_service_webos.dart' as webos_service;

/// VolumeService - webOS Luna Service 사용
///
/// luna://com.webos.audio API를 통한 볼륨 제어
VolumeService getVolumeService() {
  debugPrint('[VolumeService] webOS Luna Service 사용');
  return webos_service.getVolumeService();
}

