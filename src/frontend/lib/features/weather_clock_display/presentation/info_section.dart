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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. 시간 표시
        ClockWidget(
          width: 269,
          textColor: primaryColor,
        ),

        const SizedBox(width: 35), // gap

        // 2. 구분선 (세로)
        Container(
          width: 1,
          height: 71,
          color: divColor,
        ),

        const SizedBox(width: 35), // gap

        // 3. 날씨 표시
        WeatherWidget(
          cityName: cityName,
          textColor: primaryColor,
          showLoading: showWeatherLoading,
        ),
      ],
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
        final isMobile = constraints.maxWidth < mobileBreakpoint;

        if (isMobile) {
          // 모바일: 세로 레이아웃
          return _buildVerticalLayout();
        } else {
          // 데스크톱: 가로 레이아웃
          return InfoSection(
            cityName: cityName,
            textColor: textColor,
            showWeatherLoading: true,
          );
        }
      },
    );
  }

  Widget _buildVerticalLayout() {
    final primaryColor = textColor ?? const Color(0xFF6B6B6B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 시간
        ClockWidget(
          width: 200, // 모바일에서 축소
          textColor: primaryColor,
        ),

        const SizedBox(height: 20),

        // 구분선 (가로)
        Container(
          width: 71,
          height: 1,
          color: primaryColor,
        ),

        const SizedBox(height: 20),

        // 날씨
        WeatherWidget(
          cityName: cityName,
          textColor: primaryColor,
          showLoading: true,
        ),
      ],
    );
  }
}
