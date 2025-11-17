/// 미디어 아이템 모델
class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnail,
    this.duration,
    this.type = MediaType.video,
  });

  final String id;
  final String title;
  final String url;
  final String? thumbnail;
  final Duration? duration;
  final MediaType type;

  MediaItem copyWith({
    String? id,
    String? title,
    String? url,
    String? thumbnail,
    Duration? duration,
    MediaType? type,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      type: type ?? this.type,
    );
  }
}

/// 미디어 타입
enum MediaType {
  video,
  audio,
}

/// 미디어 재생 상태
enum MediaPlaybackState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}
