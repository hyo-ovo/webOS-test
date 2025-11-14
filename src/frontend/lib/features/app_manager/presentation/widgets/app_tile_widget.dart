import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/app_info.dart';

class AppTileWidget extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;

  const AppTileWidget({
    super.key,
    required this.app,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildIcon(),
              ),
            ),
            const SizedBox(height: 8),
            // 앱 이름
            Text(
              app.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 앱 아이콘 위젯 빌드
  Widget _buildIcon() {
    // 아이콘 경로가 비어있으면 기본 아이콘 표시
    if (app.icon.isEmpty) {
      return _buildFallbackIcon();
    }

    // webOS 시스템 경로 - Image.network()에 file:// 프로토콜로 시도
    final iconPath = app.icon;

    print('🖼️ 아이콘 로드 시도: ${app.title} - $iconPath');

    return Image.network(
      iconPath,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('⚠️ Image.network 실패: ${app.title}');
        print('   Path: $iconPath');
        print('   Error: $error');

        // Image.network 실패 시 Image.file로 한번 더 시도
        return Image.file(
          File(iconPath.substring(1)),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) {
            print('⚠️ Image.file도 실패: ${app.title}');
            print('   Path: $iconPath');
            print('   Error: $error');
            return _buildFallbackIcon();
          },
        );
      },
    );
  }

  /// 기본 아이콘 (로드 실패 시)
  Widget _buildFallbackIcon() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.blue.shade700,
      child: const Icon(
        Icons.apps,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
