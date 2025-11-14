import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/clock_service.dart';

/// 시간 위젯 (디자인 명세서 버전)
///
/// 디자인 명세:
/// - 컨테이너: 269px width
/// - 시간: Inter Regular 72px, #6B6B6B
/// - AM/PM: Inter Regular 36px, #6B6B6B
/// - 레이아웃: Horizontal Flexbox, items-end, justify-between
/// - 패딩: bottom 6px
///
/// 환경 자동 감지:
/// - webOS: Luna Service 사용
/// - 로컬: DateTime.now() 사용
class ClockWidget extends StatefulWidget {
  final double? width;
  final Color? textColor;
  final double? fontSize;
  final double? amPmFontSize;
  final double? height;
  final double verticalOffset;

  const ClockWidget({
    super.key,
    this.width,
    this.textColor,
    this.fontSize,
    this.amPmFontSize,
    this.height,
    this.verticalOffset = 0,
  });

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late ClockService _clockService;

  @override
  void initState() {
    super.initState();
    _clockService = ClockService();
    _clockService.start();
  }

  @override
  void dispose() {
    _clockService.stop();
    _clockService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _clockService,
      child: Consumer<ClockService>(
        builder: (context, clock, child) {
          final time = clock.currentTime;
          final hour = time.hour;
          final minute = time.minute;

          // 12시간 형식으로 변환
          final hour12 = hour % 12 == 0 ? 12 : hour % 12;
          final amPm = hour >= 12 ? 'PM' : 'AM';

          final timeString =
              '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          final timeFontSize = widget.fontSize ?? 72;
          final amPmFontSize = widget.amPmFontSize ?? 36;

          return SizedBox(
            width: widget.width ?? 269,
            height: widget.height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(0, widget.verticalOffset),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 시간 표시 (HH:MM)
                    Text(
                      timeString,
                      style: GoogleFonts.inter(
                        fontSize: timeFontSize,
                        fontWeight: FontWeight.w400, // Regular
                        color: widget.textColor ?? const Color(0xFF6B6B6B),
                        height: 1.0,
                        letterSpacing: 0.123,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // AM/PM 표시
                    Text(
                      amPm,
                      style: GoogleFonts.inter(
                        fontSize: amPmFontSize,
                        fontWeight: FontWeight.w400, // Regular
                        color: widget.textColor ?? const Color(0xFF6B6B6B),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}