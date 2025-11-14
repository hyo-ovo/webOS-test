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

  Future<void> _initializeVideo() async {
    if (_isInitializing || _controller != null) return;
    
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );
      
      await _controller!.initialize();
      
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double targetWidth = widget.width ?? MediaQuery.of(context).size.width;
    final double targetHeight = widget.height ?? targetWidth / (16 / 9);

    return SizedBox(
      width: targetWidth,
      height: targetHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 비디오 플레이어 또는 썸네일
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            else
              Container(
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
            // 그라데이션 오버레이
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
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
  }
}

