import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../memo/data/models/memo.dart';
import '../../memo/logic/luna_keyboard_service.dart';
import '../../memo/logic/memo_controller.dart';

class MemoBoardWidget extends StatefulWidget {
  const MemoBoardWidget({super.key});

  @override
  State<MemoBoardWidget> createState() => _MemoBoardWidgetState();
}

class _MemoBoardWidgetState extends State<MemoBoardWidget> {
  late final MemoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MemoController();
    _controller.loadMemos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MemoController>(
        builder: (context, controller, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isLoading)
                const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 12),
              _MemoGrid(controller: controller),
              if (controller.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MemoGrid extends StatelessWidget {
  const _MemoGrid({required this.controller});

  final MemoController controller;

  @override
  Widget build(BuildContext context) {
    final memoSlots = controller.memoSlots;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final memo = memoSlots[index];
        final memoType = index + 1;
        return _MemoCard(
          memoType: memoType,
          memo: memo,
          onTap: () => _onTap(context, memoType, memo?.content),
          onDelete: memo == null
              ? null
              : () => controller.deleteMemo(memoType),
        );
      },
    );
  }

  Future<void> _onTap(
    BuildContext context,
    int memoType,
    String? initialText,
  ) async {
    final content = await LunaKeyboardService.requestText(
      context,
      initialText: initialText,
      title: '메모 $memoType',
    );
    if (content == null || content.isEmpty) return;
    await controller.saveMemo(memoType: memoType, content: content);
  }
}

class _MemoCard extends StatelessWidget {
  const _MemoCard({
    required this.memoType,
    this.memo,
    this.onTap,
    this.onDelete,
  });

  final int memoType;
  final Memo? memo;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasMemo = memo != null;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: hasMemo
              ? const Color(0xFFF5F6FB)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Memo $memoType',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1F25),
                  ),
                ),
                if (hasMemo && onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: hasMemo
                  ? Text(
                      memo!.content,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF3B3F46),
                      ),
                      overflow: TextOverflow.fade,
                    )
                  : Center(
                      child: Text(
                        '+ 메모 추가',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.4),
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


