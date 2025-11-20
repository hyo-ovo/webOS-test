import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/weather_controller.dart';

/// 날씨 위젯 (디자인 명세서 버전)
///
/// 디자인 명세:
/// - 레이아웃: Horizontal Flexbox, items-center, justify-end
/// - 간격: gap 19px
/// - 패딩: bottom 6px
/// - 날씨 아이콘: 50×50px, 그라디언트 (#EFC977 → #E07256)
/// - 온도: Inter Regular 72px, #6B6B6B
/// - 섭씨 기호: 65×65px
class WeatherWidget extends StatefulWidget {
  final String? cityName;
  final Color? textColor;
  final bool showLoading;
  final double? iconSize;
  final double? temperatureFontSize;
  final double? unitFontSize;
  final double? conditionFontSize;
  final bool showCondition;
  final double? height;
  final double textVerticalOffset;
  final double iconVerticalOffset;

  const WeatherWidget({
    super.key,
    this.cityName,
    this.textColor,
    this.showLoading = false,
    this.iconSize,
    this.temperatureFontSize,
    this.unitFontSize,
    this.conditionFontSize,
    this.showCondition = false,
    this.height,
    this.textVerticalOffset = 0,
    this.iconVerticalOffset = 0,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late WeatherController _weatherController;

  @override
  void initState() {
    super.initState();
    _weatherController = WeatherController();
    _weatherController.loadWeather(cityName: widget.cityName);
    if (widget.showLoading) {
      _weatherController.startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _weatherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _weatherController,
      child: Consumer<WeatherController>(
        builder: (context, controller, child) {
          final iconSize = widget.iconSize ?? 50.0;
          final temperature = controller.weather?.temperature.toInt() ?? 17;
          final unitFontSize = widget.unitFontSize ?? 28.0;
          final tempFontSize = widget.temperatureFontSize ?? 72.0;
          final conditionFontSize = widget.conditionFontSize ?? 18.0;
          final condition = controller.weather?.condition ?? '맑음';
          final textColor = widget.textColor ?? const Color(0xFF6B6B6B);

          final temperatureText = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                temperature.toString(),
                style: GoogleFonts.inter(
                  fontSize: tempFontSize,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.0,
                  letterSpacing: 0.123,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '°',
                style: GoogleFonts.inter(
                  fontSize: unitFontSize * 0.6,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                'C',
                style: GoogleFonts.inter(
                  fontSize: unitFontSize,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ],
          );

          Widget temperatureSection;
          if (widget.showCondition) {
            temperatureSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                temperatureText,
                const SizedBox(height: 6),
                Text(
                  condition,
                  style: GoogleFonts.inter(
                    fontSize: conditionFontSize,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ],
            );
          } else {
            temperatureSection = temperatureText;
          }

          final content = Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 날씨 아이콘 (태양)
              Transform.translate(
                offset: Offset(0, widget.iconVerticalOffset),
                child: _buildWeatherIcon(
                  controller,
                  iconSize: iconSize,
                ),
              ),
              const SizedBox(width: 19), // gap
              Transform.translate(
                offset: Offset(0, widget.textVerticalOffset),
                child: temperatureSection,
              ),
            ],
          );

          final wrapped = Padding(
            padding: EdgeInsets.zero,
            child: content,
          );

          if (widget.height != null) {
            return SizedBox(
              height: widget.height,
              child: Align(
                alignment: Alignment.centerLeft,
                child: wrapped,
              ),
            );
          }

          return wrapped;
        },
      ),
    );
  }

  /// 날씨 아이콘 생성 (그라디언트 태양)
  Widget _buildWeatherIcon(
    WeatherController controller, {
    required double iconSize,
  }) {
    final condition = controller.weather?.condition ?? '맑음';
    final isLoading = controller.isLoading;

    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            widget.textColor ?? const Color(0xFF6B6B6B),
          ),
        ),
      );
    }

    // 날씨에 따른 아이콘 선택
    IconData icon;
    if (condition.contains('비') || condition.contains('Rain')) {
      icon = Icons.water_drop;
    } else if (condition.contains('구름') ||
        condition.contains('흐림') ||
        condition.contains('Cloud')) {
      icon = Icons.cloud;
    } else {
      icon = Icons.wb_sunny; // 맑음 (기본)
    }

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFC977), // 밝은 주황
            Color(0xFFE07256), // 진한 주황
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize * 0.6, // padding 적용
      ),
    );
  }
}