abstract class VolumeService {
  Future<bool> volumeUp();

  Future<bool> volumeDown();

  Future<bool> setMuted(bool muted);
}

