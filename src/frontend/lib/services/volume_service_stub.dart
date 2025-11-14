import 'dart:async';

import 'package:flutter/foundation.dart';

import 'volume_service_interface.dart';

VolumeService getVolumeService() => _StubVolumeService();

class _StubVolumeService implements VolumeService {
  static int _volumeLevel = 15;

  @override
  Future<bool> volumeUp() async {
    _volumeLevel = (_volumeLevel + 1).clamp(0, 100).toInt();
    debugPrint('[volume] volumeUp -> $_volumeLevel (stub)');
    return true;
  }

  @override
  Future<bool> volumeDown() async {
    _volumeLevel = (_volumeLevel - 1).clamp(0, 100).toInt();
    debugPrint('[volume] volumeDown -> $_volumeLevel (stub)');
    return true;
  }

  @override
  Future<bool> setMuted(bool muted) async {
    debugPrint('[volume] setMuted($muted) (stub)');
    return true;
  }
}

