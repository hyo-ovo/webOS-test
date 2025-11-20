import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/controllers/volume_controller.dart';

/// 시스템 볼륨 조절 위젯
///
/// Luna API를 사용하여 시스템 볼륨을 조절하는 위젯
class VolumeControlWidget extends StatefulWidget {
  /// 위젯의 크기 (높이)
  final double? height;

  /// 배경색
  final Color? backgroundColor;

  /// 텍스트 색상
  final Color? textColor;

  /// 아이콘 색상
  final Color? iconColor;

  const VolumeControlWidget({
    super.key,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  State<VolumeControlWidget> createState() => _VolumeControlWidgetState();
}

class _VolumeControlWidgetState extends State<VolumeControlWidget> {
  late VolumeController _volumeController;

  @override
  void initState() {
    super.initState();
    _volumeController = VolumeController();
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _volumeController,
      child: Consumer<VolumeController>(
        builder: (context, controller, child) {
          return Container(
            height: widget.height ?? 80,
            decoration: BoxDecoration(
              color: widget.backgroundColor ??
                  Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 음소거 버튼
                _buildMuteButton(controller),

                const SizedBox(width: 16),

                // 볼륨 감소 버튼
                _buildVolumeButton(
                  icon: Icons.volume_down,
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.volumeDown(),
                  controller: controller,
                ),

                const SizedBox(width: 8),

                // 볼륨 증가 버튼
                _buildVolumeButton(
                  icon: Icons.volume_up,
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.volumeUp(),
                  controller: controller,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 음소거 버튼
  Widget _buildMuteButton(VolumeController controller) {
    final isMuted = controller.isMuted;
    final isLoading = controller.isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => controller.toggleMute(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMuted
                ? Colors.red.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMuted
                  ? Colors.red.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            isMuted ? Icons.volume_off : Icons.volume_up,
            color: widget.iconColor ??
                (isMuted ? Colors.red : Colors.white),
            size: 28,
          ),
        ),
      ),
    );
  }

  /// 볼륨 조절 버튼
  Widget _buildVolumeButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required VolumeController controller,
  }) {
    final isLoading = controller.isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.iconColor ?? Colors.white,
                    ),
                  ),
                )
              : Icon(
                  icon,
                  color: widget.iconColor ?? Colors.white,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

