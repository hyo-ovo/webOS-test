import 'media_service_interface.dart';
import 'media_service_stub.dart';

export 'media_service_interface.dart';

/// webOS 전용 MediaService
/// Luna Service API (luna://com.webos.media) 사용
MediaService get mediaService => getMediaService();
