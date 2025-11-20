import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/webos_service_helper/utils.dart' as luna_utils;

/// 입력을 위해 webOS Luna 키보드를 호출하는 헬퍼.
class LunaKeyboardService {
  static const String _keyboardUri = 'luna://com.webos.service.ime';

  static Future<String?> requestText(
    BuildContext context, {
    String? initialText,
    String? title,
  }) async {
    if (!kIsWeb) {
      try {
        final result = await luna_utils.callOneReply(
          uri: _keyboardUri,
          method: 'showKeyboard',
          payload: <String, dynamic>{
            'type': 'text',
            if (title != null) 'title': title,
            'text': initialText ?? '',
          },
        );

        if (result?['returnValue'] == true && result?['text'] is String) {
          return (result?['text'] as String).trim();
        }
      } catch (e) {
        debugPrint('[LunaKeyboardService] Luna call failed: $e');
      }
    }

    return _showFallbackDialog(
      context,
      initialText: initialText,
      title: title,
    );
  }

  static Future<String?> _showFallbackDialog(
    BuildContext context, {
    String? initialText,
    String? title,
  }) {
    final controller = TextEditingController(text: initialText ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? '메모 입력'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(hintText: '내용을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}


