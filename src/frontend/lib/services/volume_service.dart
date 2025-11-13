import 'volume_service_interface.dart';
import 'volume_service_stub.dart'
    if (dart.library.io) 'volume_service_web.dart';

VolumeService get volumeService => getVolumeService();

