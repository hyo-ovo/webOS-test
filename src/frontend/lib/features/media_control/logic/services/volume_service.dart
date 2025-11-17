import 'volume_service_interface.dart';
import 'volume_service_stub.dart';

/// webOS 전용 VolumeService
/// Luna Service API (luna://com.webos.audio) 사용
VolumeService get volumeService => getVolumeService();

