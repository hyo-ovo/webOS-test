/// Luna API의 listLaunchPoints 응답 형식에 맞춘 앱 정보 모델
class AppInfo {
  /// 앱 ID (예: "com.webos.app.browser") - launch API에 필요
  final String id;

  /// 런치 포인트 ID (예: "com.webos.app.browser_default")
  final String launchPointId;

  /// 앱 표시 이름 (예: "Web Browser")
  final String title;

  /// 아이콘 파일 경로 (예: "/usr/palm/applications/com.webos.app.browser/icon.png")
  final String icon;

  /// 아이콘 색상 (예: "#FFFFFF")
  final String? iconColor;

  /// 배경 색상 (예: "#000000")
  final String? bgColor;

  /// 배경 이미지 경로
  final String? bgImage;

  /// 큰 아이콘 경로
  final String? largeIcon;

  /// 앱 설명
  final String? appDescription;

  /// 앱 실행 시 전달할 파라미터 (launch API에 사용)
  final Map<String, dynamic>? params;

  AppInfo({
    required this.id,
    required this.launchPointId,
    required this.title,
    required this.icon,
    this.iconColor,
    this.bgColor,
    this.bgImage,
    this.largeIcon,
    this.appDescription,
    this.params,
  });

  /// Luna API listLaunchPoints 응답에서 AppInfo 생성
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      id: json['id'] as String,
      launchPointId: json['launchPointId'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      iconColor: json['iconColor'] as String?,
      bgColor: json['bgColor'] as String?,
      bgImage: json['bgImage'] as String?,
      largeIcon: json['largeIcon'] as String?,
      appDescription: json['appDescription'] as String?,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'launchPointId': launchPointId,
      'title': title,
      'icon': icon,
      'iconColor': iconColor,
      'bgColor': bgColor,
      'bgImage': bgImage,
      'largeIcon': largeIcon,
      'appDescription': appDescription,
      'params': params,
    };
  }

  /// 복사본 생성 (순서 변경 등에 사용)
  AppInfo copyWith({
    String? id,
    String? launchPointId,
    String? title,
    String? icon,
    String? iconColor,
    String? bgColor,
    String? bgImage,
    String? largeIcon,
    String? appDescription,
    Map<String, dynamic>? params,
  }) {
    return AppInfo(
      id: id ?? this.id,
      launchPointId: launchPointId ?? this.launchPointId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      bgColor: bgColor ?? this.bgColor,
      bgImage: bgImage ?? this.bgImage,
      largeIcon: largeIcon ?? this.largeIcon,
      appDescription: appDescription ?? this.appDescription,
      params: params ?? this.params,
    );
  }
}
