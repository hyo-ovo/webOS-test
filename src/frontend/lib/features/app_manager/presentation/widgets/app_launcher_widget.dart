import 'package:flutter/material.dart';
import '../../data/models/app_info.dart';
import '../../data/app_manager_service.dart';
import '../../data/app_order_api.dart';
import 'app_tile_widget.dart';

class AppLauncherWidget extends StatefulWidget {
  const AppLauncherWidget({super.key});

  @override
  State<AppLauncherWidget> createState() => _AppLauncherWidgetState();
}

class _AppLauncherWidgetState extends State<AppLauncherWidget> {
  List<AppInfo> apps = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  /// Luna API로 실제 설치된 앱 목록 불러오기 + 백엔드에서 순서 적용
  Future<void> _loadInstalledApps() async {
    try {
      print('📱 설치된 앱 목록 불러오는 중...');

      final result = await AppManagerService.listLaunchPoints();

      if (result != null && result['returnValue'] == true) {
        final launchPoints = result['launchPoints'] as List?;

        if (launchPoints != null) {
          List<AppInfo> loadedApps = launchPoints
              .map((app) => AppInfo.fromJson(app as Map<String, dynamic>))
              .toList();

          // TODO: 인증 시스템 구현 후 실제 토큰 사용
          // 임시: 토큰 없이 순서 불러오기 시도
          try {
            // 백엔드에서 저장된 앱 순서 불러오기
            final savedOrder = await AppOrderApi.getUserAppOrder('temp-token');

            if (savedOrder.isNotEmpty) {
              // 저장된 순서대로 정렬
              loadedApps = _sortAppsByOrder(loadedApps, savedOrder);
              print('✅ 저장된 순서 적용 완료');
            }
          } catch (e) {
            print('⚠️ 저장된 순서 불러오기 실패 (기본 순서 사용): $e');
          }

          setState(() {
            apps = loadedApps;
            isLoading = false;
          });

          print('✅ 앱 목록 로드 성공: ${apps.length}개');
        } else {
          throw Exception('launchPoints가 null입니다');
        }
      } else {
        throw Exception(result?['errorText'] ?? 'Unknown error');
      }
    } catch (e) {
      print('❌ 앱 목록 로드 실패: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// 저장된 순서에 따라 앱 목록 정렬
  List<AppInfo> _sortAppsByOrder(List<AppInfo> apps, List<String> order) {
    final Map<String, AppInfo> appMap = {for (var app in apps) app.id: app};
    final List<AppInfo> sortedApps = [];

    // 저장된 순서대로 추가
    for (final id in order) {
      if (appMap.containsKey(id)) {
        sortedApps.add(appMap[id]!);
        appMap.remove(id);
      }
    }

    // 순서에 없는 앱들은 뒤에 추가
    sortedApps.addAll(appMap.values);

    return sortedApps;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: _buildContent(),
    );
  }

  /// 상태에 따라 다른 UI 표시
  Widget _buildContent() {
    // 로딩 중
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 8),
            Text(
              '설치된 앱 목록 불러오는 중...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // 에러 발생
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              '앱 목록 로드 실패',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadInstalledApps();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 앱 목록이 비어있음
    if (apps.isEmpty) {
      return const Center(
        child: Text(
          '설치된 앱이 없습니다',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    // 앱 목록 표시 (드래그 앤 드롭 가능)
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: apps.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final app = apps.removeAt(oldIndex);
          apps.insert(newIndex, app);
        });

        print('📦 앱 순서 변경: ${apps[oldIndex].title} ($oldIndex → $newIndex)');

        // 백엔드에 순서 저장
        _saveAppOrder();
      },
      itemBuilder: (context, index) {
        return AppTileWidget(
          key: ValueKey(apps[index].id), // 드래그 앤 드롭을 위한 고유 키
          app: apps[index],
          onTap: () => _onAppTap(apps[index]),
        );
      },
    );
  }

  /// 변경된 앱 순서를 백엔드에 저장
  Future<void> _saveAppOrder() async {
    try {
      final order = apps.map((app) => app.id).toList();

      // TODO: 인증 시스템 구현 후 실제 토큰 사용
      final success = await AppOrderApi.saveUserAppOrder('temp-token', order);

      if (success) {
        print('✅ 앱 순서 백엔드 저장 완료');
      }
    } catch (e) {
      print('⚠️ 앱 순서 저장 실패: $e');
    }
  }

  void _onAppTap(AppInfo app) async {
    print('앱 실행 시도: ${app.title} (${app.id})');

    try {
      // Luna API로 앱 실행
      final result = await AppManagerService.launchApp(
        app.id,
        params: app.params,
      );

      if (result != null && result['returnValue'] == true) {
        print('✅ 앱 실행 성공!');
        print('   - App ID: ${result['appId']}');
        print('   - Instance ID: ${result['instanceId']}');
      } else {
        print('❌ 앱 실행 실패');
        print('   - Error: ${result?['errorText'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ 앱 실행 중 예외 발생: $e');
    }
  }
}
