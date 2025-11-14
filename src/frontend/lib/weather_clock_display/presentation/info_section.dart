import 'package:flutter/material.dart';
import 'clock_widget.dart';
import 'weather_widget.dart';

/// 통합 위젯 (디자인 명세서 버전)
///
/// 디자인 명세:
/// - 레이아웃: Horizontal Flexbox, items-center, justify-center
/// - 간격: gap 35px
/// - 구성: 시간 (269px) | 구분선 (71px × 1px) | 날씨
/// - 구분선: #6B6B6B, 세로 실선
class InfoSection extends StatelessWidget {
  static const double clockAreaWidth = 269;
  static const double weatherAreaWidth = 220;
  static const double dividerWidth = 1;
  static const double gap = 35;
  static const double baseHeight = 90;
  static const double baseWidth =
      clockAreaWidth + weatherAreaWidth + (gap * 2) + dividerWidth;

  final String? cityName;
  final Color? textColor;
  final Color? dividerColor;
  final bool showWeatherLoading;

  const InfoSection({
    super.key,
    this.cityName,
    this.textColor,
    this.dividerColor,
    this.showWeatherLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = textColor ?? const Color(0xFF6B6B6B);
    final divColor = dividerColor ?? const Color(0xFF6B6B6B);

    return SizedBox(
      width: baseWidth,
      height: baseHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: clockAreaWidth,
            height: baseHeight,
            child: Align(
              alignment: Alignment.centerRight,
              child: ClockWidget(
                width: clockAreaWidth,
                height: baseHeight,
                textColor: primaryColor,
                fontSize: 72,
                amPmFontSize: 36,
                verticalOffset: -6,
              ),
            ),
          ),
          const SizedBox(width: gap),
          Container(width: dividerWidth, height: baseHeight, color: divColor),
          const SizedBox(width: gap),
          SizedBox(
            width: weatherAreaWidth,
            height: baseHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(-8, 0),
                child: WeatherWidget(
                  cityName: cityName,
                  textColor: primaryColor,
                  showLoading: showWeatherLoading,
                  iconSize: 50,
                  temperatureFontSize: 72,
                  unitFontSize: 65,
                  conditionFontSize: 18,
                  showCondition: false,
                  height: baseHeight,
                  textVerticalOffset: -6,
                  iconVerticalOffset: -4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 반응형 통합 위젯
///
/// 모바일: 세로 레이아웃
/// 데스크톱: 가로 레이아웃
class ResponsiveInfoSection extends StatelessWidget {
  final String? cityName;
  final Color? textColor;
  final double mobileBreakpoint;

  const ResponsiveInfoSection({
    super.key,
    this.cityName,
    this.textColor,
    this.mobileBreakpoint = 600,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final infoSection = InfoSection(
          cityName: cityName,
          textColor: textColor,
          showWeatherLoading: true,
        );

        final shouldScale = constraints.maxWidth < mobileBreakpoint ||
            constraints.maxWidth < InfoSection.baseWidth;

        if (shouldScale) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: infoSection,
            ),
          );
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: infoSection,
        );
      },
    );
  }
}
