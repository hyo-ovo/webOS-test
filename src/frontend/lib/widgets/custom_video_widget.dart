import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoWidget extends StatefulWidget {
  const CustomVideoWidget({
    super.key,
    this.thumbnail,
    this.onPlay,
    this.width,
    this.height,
    this.caption,
    this.videoUrl,
  });

  final ImageProvider? thumbnail;
  final VoidCallback? onPlay;
  final double? width;
  final double? height;
  final String? caption;
  final String? videoUrl;

  @override
  State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
}

class _CustomVideoWidgetState extends State<CustomVideoWidget> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(CustomVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // videoUrl이 변경되면 새로운 비디오 초기화
    if (widget.videoUrl != null && widget.videoUrl != oldWidget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _initializeVideo();
    }
  }

  static const String _defaultVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  Future<void> _initializeVideo() async {
    if (_isInitializing || _controller != null) return;
    
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final videoUrl = widget.videoUrl ?? _defaultVideoUrl;

      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      // 비디오 상태 리스너 추가
      _controller!.addListener(_videoListener);
      
      await _controller!.initialize();
      
      // 반복 재생 설정
      await _controller!.setLooping(true);
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        await _controller!.play();
        await _controller!.setVolume(0.5);
      }
    } catch (e) {
      debugPrint('[CustomVideoWidget] 비디오 초기화 에러: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller == null) return;
    
    // 비디오 상태 변화 시 UI 업데이트만 수행 (로깅 제거)
    if (mounted) {
      setState(() {
        // 상태 변화를 감지하여 UI 업데이트
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        double resolvedWidth = widget.width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : mediaSize.width);
        double resolvedHeight = widget.height ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : resolvedWidth / (16 / 9));

        if (!resolvedWidth.isFinite) {
          resolvedWidth = mediaSize.width;
        }
        if (!resolvedHeight.isFinite) {
          resolvedHeight = resolvedWidth / (16 / 9);
        }

        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_controller != null && _controller!.value.isInitialized)
                  LayoutBuilder(
                    builder: (_, boxConstraints) {
                      final value = _controller!.value;
                      final Size intrinsicSize = value.size;
                      double videoWidth =
                          intrinsicSize.width > 0 ? intrinsicSize.width : resolvedWidth;
                      double videoHeight =
                          intrinsicSize.height > 0 ? intrinsicSize.height : resolvedHeight;

                      final double widgetAspect = resolvedWidth / resolvedHeight;
                      final double videoAspect =
                          (videoWidth > 0 && videoHeight > 0) ? videoWidth / videoHeight : widgetAspect;

                      if (videoAspect < widgetAspect) {
                        videoWidth = resolvedWidth;
                        videoHeight = videoWidth / videoAspect;
                      } else {
                        videoHeight = resolvedHeight;
                        videoWidth = videoHeight * videoAspect;
                      }

                      return Center(
                        child: SizedBox(
                          width: videoWidth,
                          height: videoHeight,
                          child: ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: videoWidth,
                                height: videoHeight,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  ColoredBox(
                    color: Colors.black.withOpacity(0.2),
                    child: widget.thumbnail != null
                        ? Image(
                            image: widget.thumbnail!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(
                              Icons.videocam_rounded,
                              size: 64,
                              color: Colors.white70,
                            ),
                          ),
                  ),
                // 로딩 또는 에러 메시지
            if (_isInitializing)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            else if (_hasError)
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      '비디오 로드 실패',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            else if (widget.onPlay != null)
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: widget.onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('재생'),
                ),
              )
            else if (widget.caption != null && _controller == null)
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      widget.caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
        );
      },
    );
  }
}

